import 'package:ehealth/core/constants/api_constants.dart';
import 'package:ehealth/core/router/app_router.dart';
import 'package:ehealth/core/router/route_names.dart';
import 'package:ehealth/core/theme/app_theme.dart';
import 'package:ehealth/core/utils/dialer.dart';
import 'package:ehealth/features/video_call/domain/entities/doctor.dart';
import 'package:ehealth/features/video_call/presentation/providers/video_call_providers.dart';
import 'package:ehealth/features/voice_assistant/domain/entities/voice_intent.dart';
import 'package:ehealth/features/voice_assistant/presentation/providers/voice_assistant_controller.dart';
import 'package:ehealth/features/voice_assistant/presentation/providers/voice_assistant_state.dart';
import 'package:ehealth/features/voice_assistant/presentation/widgets/draggable_mic_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

bool _isFrontFacingCamera = true;

bool _isOnCallScreen(GoRouter router) =>
    router.state.name == RouteNames.videoCall;

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    ref.listen(voiceAssistantControllerProvider, (previous, next) {
      final intent = next.pendingIntent;
      if (intent == null) return;
      ref.read(voiceAssistantControllerProvider.notifier).clearPendingIntent();
      _handleIntent(ref, intent, next);
    });

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
      routerConfig: router,
      builder: (context, child) {
        return Overlay(
          initialEntries: [
            OverlayEntry(
              builder: (context) => Stack(
                children: [
                  child ?? const SizedBox.shrink(),
                  const DraggableMicButton(),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleIntent(
    WidgetRef ref,
    VoiceIntent intent,
    VoiceAssistantState state,
  ) async {
    final router = ref.read(goRouterProvider);
    final voice = ref.read(voiceAssistantControllerProvider.notifier);

    switch (intent) {
      case NavigateHomeIntent():
        router.goNamed(RouteNames.home);
        await voice.speak('Going home.');

      case FindNearbyHospitalsIntent():
        router.pushNamed(RouteNames.hospitalList);
        await voice.speak('Showing hospitals near you.');

      case ShowHospitalsOnMapIntent():
        router.pushNamed(RouteNames.hospitalMap);
        await voice.speak('Here is the hospital map.');

      case CallEmergencyIntent():
        await voice.speak('Calling emergency services now.');
        await dialPhoneNumber(AppConstants.emergencyServiceNumber);

      case OpenDoctorListIntent():
        router.pushNamed(RouteNames.doctorList);
        await voice.speak('Here are the available doctors.');

      case StartVideoCallIntent(:final doctorName):
        await _startVideoCall(ref, doctorName);

      case EndCallIntent():
        final callContext = router.routerDelegate.navigatorKey.currentContext;
        final endedCall =
            callContext != null &&
            await ZegoUIKitPrebuiltCallController().hangUp(
              callContext,
              showConfirmation: false,
            );
        await voice.speak(
          endedCall ? 'Call ended.' : "You're not in a call right now.",
        );

      case SetMicrophoneIntent(:final turnOn):
        if (!_isOnCallScreen(router)) {
          await voice.speak("You're not in a call right now.");
        } else {
          ZegoUIKitPrebuiltCallController().audioVideo.microphone.turnOn(
            turnOn,
          );
          await voice.speak(turnOn ? 'Microphone on.' : 'Microphone muted.');
        }

      case SetCameraIntent(:final turnOn):
        if (!_isOnCallScreen(router)) {
          await voice.speak("You're not in a call right now.");
        } else {
          ZegoUIKitPrebuiltCallController().audioVideo.camera.turnOn(turnOn);
          await voice.speak(turnOn ? 'Camera on.' : 'Camera off.');
        }

      case SwitchCameraIntent():
        if (!_isOnCallScreen(router)) {
          await voice.speak("You're not in a call right now.");
        } else {
          _isFrontFacingCamera = !_isFrontFacingCamera;
          ZegoUIKitPrebuiltCallController().audioVideo.camera.switchFrontFacing(
            _isFrontFacingCamera,
          );
          await voice.speak('Switching camera.');
        }

      case NavigateToAppointmentsIntent():
        router.pushNamed(RouteNames.appointmentList);
        await voice.speak('Here are your appointments.');

      case NavigateToProfileIntent():
        router.pushNamed(RouteNames.profile);
        await voice.speak('Opening your profile.');

      case NavigateToSymptomCheckerIntent():
        router.pushNamed(RouteNames.symptomChecker);
        await voice.speak('Opening the symptom checker.');

      case NavigateToHealthProgressIntent():
        router.pushNamed(RouteNames.healthProgress);
        await voice.speak('Here is your health progress.');

      case ShowVoiceCommandsHelpIntent():
        router.pushNamed(RouteNames.voiceCommands);
        await voice.speak('Here is what you can say.');

      case StopListeningIntent():
        await voice.stopListening();

      case RepeatLastResponseIntent():
        await voice.speak(
          state.lastResponse ?? "I don't have anything to repeat yet.",
        );

      case UnknownIntent():
        await voice.speak(
          "Sorry, I didn't understand that. Try saying 'find hospital' or 'call doctor'.",
        );
    }
  }

  Future<void> _startVideoCall(WidgetRef ref, String? doctorName) async {
    final voice = ref.read(voiceAssistantControllerProvider.notifier);
    final router = ref.read(goRouterProvider);

    List<Doctor> doctors;
    try {
      doctors = await ref.read(availableDoctorsProvider.future);
    } catch (_) {
      await voice.speak('I could not load the doctor list right now.');
      return;
    }

    final bookableDoctors = doctors.where((d) => d.isBookable).toList();
    if (bookableDoctors.isEmpty) {
      await voice.speak('No doctors are available for booking right now.');
      return;
    }

    final query = doctorName
        ?.replaceFirst(RegExp(r'^(a|an|the)\s+'), '')
        .trim();
    final match = query == null || query.isEmpty
        ? bookableDoctors.first
        : bookableDoctors.firstWhere(
            (d) =>
                d.doctorName.toLowerCase().contains(query.toLowerCase()) ||
                (d.specialization?.toLowerCase().contains(
                      query.toLowerCase(),
                    ) ??
                    false),
            orElse: () => bookableDoctors.first,
          );

    router.pushNamed(
      RouteNames.appointmentBooking,
      pathParameters: {'doctorId': match.doctorId.toString()},
    );
    await voice.speak("Let's book an appointment with ${match.doctorName}.");
  }
}
