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
        if (router.canPop()) router.pop();
        await voice.speak('Call ended.');

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

  /// There's no ad-hoc/instant call anymore — every call is tied to a
  /// booked consultation — so a voice request to "call" a doctor starts
  /// that doctor's booking flow instead of joining a call directly.
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

    final match = doctorName == null
        ? bookableDoctors.first
        : bookableDoctors.firstWhere(
            (d) => d.doctorName.toLowerCase().contains(doctorName.toLowerCase()),
            orElse: () => bookableDoctors.first,
          );

    router.pushNamed(
      RouteNames.appointmentBooking,
      pathParameters: {'doctorId': match.doctorId.toString()},
    );
    await voice.speak("Let's book an appointment with ${match.doctorName}.");
  }
}
