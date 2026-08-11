# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
flutter pub get                      # install dependencies (run after any pubspec.yaml edit)
flutter analyze                      # static analysis — must be clean before considering a change done
flutter test                         # run all tests
flutter test test/widget_test.dart   # run a single test file
flutter test --plain-name "App boots to the splash screen"  # run a single test by name
flutter run                          # run on a connected device/emulator
flutter build apk                    # Android release build
```

There is no `ios/` directory in this repo (Android only, no git repo initialized).

### Required local config before running

- `.env` (root, gitignored) — `GOOGLE_MAPS_API_KEY`, `GOOGLE_PLACES_API_KEY`, `ZEGO_APP_ID`, `ZEGO_APP_SIGN`, `API_BASE_URL`. Copy from `.env.example`. Read via `Env` (`lib/core/config/env.dart`), loaded once in `main()`.
- `android/local.properties` (gitignored) — needs a `MAPS_API_KEY=` line separately, because the Android `AndroidManifest.xml`'s `com.google.android.geo.API_KEY` meta-data is filled by a Gradle `manifestPlaceholders` read in `android/app/build.gradle.kts`, which cannot see the Dart-side `.env`. The two keys are set independently.

## Architecture

Clean Architecture, feature-first. Every feature under `lib/features/<name>/` is split into three layers, each only depending on the one below it:

- `domain/` — entities, abstract repository interfaces, use cases. Pure Dart, no Flutter/plugin imports.
- `data/` — models (`extends` the domain entity, add `fromJson`/plugin-mapping factories), datasources (wrap a plugin or call Dio), repository implementations (catch exceptions, return `Result<T>`).
- `presentation/` — Riverpod providers (wire domain use cases to datasources/repos), screens, widgets.

`lib/core/` holds cross-feature infrastructure: `error/` (`Failure`/`Exception` hierarchies), `result/` (`Result<T>` = `typedef Either<Failure, T>` from `dartz`), `network/` (shared `DioClient`), `usecase/` (`UseCase`/`SyncUseCase`/`NoParams` base contracts), `router/`, `theme/`, `permissions/`, `di/core_providers.dart` (dio, connectivity, permission service, and `sharedPreferencesProvider` — overridden in `main.dart` once `SharedPreferences.getInstance()` resolves, since it can't be constructed synchronously).

State management is plain Riverpod (`flutter_riverpod`) — `Provider`/`FutureProvider`/`Notifier`, **no code generation**. `riverpod_generator`/`build_runner` are present as dev deps but nothing in the codebase currently requires running `build_runner`.

### Routing

`lib/core/router/app_router.dart` defines `goRouterProvider` (a `GoRouter` built as a Riverpod `Provider`, not a global singleton) and `lib/core/router/route_names.dart` holds `RouteNames`/`RoutePaths` constants. Hospital map/detail are nested children of the hospital list route (`/hospitals/map`, `/hospitals/:placeId`) — the static `map` segment is listed before the `:placeId` wildcard in `app_router.dart` so it isn't swallowed by the parameter route; keep that order if adding siblings there.

Because `GoRouter` instances have direct `goNamed`/`pushNamed`/`pop` methods, navigation triggered from non-widget code (the voice command dispatcher) reads `goRouterProvider` directly instead of requiring a `BuildContext`.

`AppScaffold` (`lib/core/widgets/app_scaffold.dart`) is the shared scaffold for the three bottom-nav tabs (Home/Hospitals/Doctors). Full-screen routes (hospital detail/map, video call, voice assistant) use a plain `Scaffold` instead.

### Voice control (cross-cutting — read this before touching it)

The app's "control everything by voice" feature is intentionally split so the NLU logic stays pure and testable, while side effects (navigation, dialing, starting a call) live in one place:

1. `features/voice_assistant/domain/entities/voice_intent.dart` — a sealed `VoiceIntent` class defines every possible voice-triggered action.
2. `features/voice_assistant/domain/usecases/interpret_voice_command.dart` — `InterpretVoiceCommand`, a pure synchronous keyword matcher, turns raw recognized text into a `VoiceIntent`. No dependencies, easy to unit test.
3. `features/voice_assistant/presentation/providers/voice_assistant_controller.dart` — `VoiceAssistantController` (a `Notifier`) owns the speech-engine lifecycle (`speech_to_text` init/listen/stop, `flutter_tts` speak) and, on a final recognition result, calls the interpreter and stores the result as `state.pendingIntent`.
4. `lib/app.dart` — the root `App` widget `ref.listen`s to the controller. When `pendingIntent` is set, it clears it (so the intent doesn't refire on rebuild) and dispatches in `_handleIntent`: this is the only place that calls `goRouterProvider` navigation, `dialPhoneNumber`, and cross-feature providers (e.g. `availableDoctorsProvider` to fuzzy-match a doctor name for `StartVideoCallIntent`).

**To add a new voice command**, touch exactly three places: add a case to `VoiceIntent`, a matching pattern in `InterpretVoiceCommand`, and a `case` in `App._handleIntent`. Don't let navigation or plugin calls leak into the domain or controller layers.

The mic button (`VoiceMicButton`) is rendered globally on every screen via `MaterialApp.router`'s `builder` in `lib/app.dart`, which wraps `child` in its own `Overlay` — this is required because a sibling `Positioned` widget outside `child` has no ancestor `Overlay`/`Navigator` of its own otherwise (the button's `Tooltip` needs one). Don't remove that `Overlay` wrapper without another way of satisfying that ancestor requirement.

### Google Places / hospitals

`HospitalRepositoryImpl` calls Google's Nearby Search then, per-hospital, Place Details (for the phone number, used as that hospital's "emergency contact number") — see `features/hospital/data/datasources/hospital_remote_data_source.dart`. Distance is computed client-side with `Geolocator.distanceBetween` against the current position, not returned by the Places API.

### Video calls

`features/video_call/data/datasources/doctor_local_data_source.dart` is a **mock/local stand-in** for a real doctor-directory backend — swap it for a Dio-based remote datasource when that API exists; nothing above the repository needs to change. `VideoCallRepositoryImpl.createCallSession` derives a deterministic ZEGOCLOUD room id from `doctor.id` + `callerUserId`; a production backend should instead mint a signed token server-side.

### Known dependency constraint

`zego_uikit_prebuilt_call` and `permission_handler` are version-coupled: at the time of writing, `zego_uikit_prebuilt_call ^4.16.x` resolves to a `zego_uikit`/`zego_plugin_adapter` combination that fails to compile (transitive version mismatch upstream), and `zego_uikit_prebuilt_call >=4.24` requires `permission_handler ^12`. Both are already pinned compatibly in `pubspec.yaml` — if you bump one, run `flutter pub get` and `flutter test` (not just `flutter analyze`, which won't catch it) immediately, since these transitive breaks only surface at compile/kernel time.
