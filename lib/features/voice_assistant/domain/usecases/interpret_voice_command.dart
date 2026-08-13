import 'package:ehealth/core/usecase/usecase.dart';
import 'package:ehealth/features/voice_assistant/domain/entities/voice_intent.dart';

/// Pure keyword-based NLU: turns raw recognized speech into a [VoiceIntent].
///
/// Kept dependency-free and synchronous so it's trivial to unit test and so
/// every new voice-controllable action only requires adding a pattern here
/// plus a case in `VoiceCommandListener` — no plugin or navigation code
/// leaks into the domain layer.
class InterpretVoiceCommand implements SyncUseCase<VoiceIntent, String> {
  const InterpretVoiceCommand();

  @override
  VoiceIntent call(String params) {
    final text = params.toLowerCase().trim();
    if (text.isEmpty) return UnknownIntent(params);

    if (_matchesAny(text, ['stop listening', 'stop', 'cancel', 'never mind'])) {
      return const StopListeningIntent();
    }

    if (_matchesAny(text, [
      'emergency',
      'call 999',
      'call ambulance',
      'help me',
    ])) {
      return const CallEmergencyIntent();
    }

    if (_matchesAny(text, [
      'end call',
      'hang up',
      'disconnect call',
      'leave call',
    ])) {
      return const EndCallIntent();
    }

    if (_matchesAny(text, [
      'unmute',
      'turn on microphone',
      'turn on mic',
      'enable microphone',
    ])) {
      return const SetMicrophoneIntent(turnOn: true);
    }

    if (_matchesAny(text, [
      'mute',
      'turn off microphone',
      'turn off mic',
      'disable microphone',
    ])) {
      return const SetMicrophoneIntent(turnOn: false);
    }

    if (_matchesAny(text, ['turn on camera', 'enable camera', 'camera on'])) {
      return const SetCameraIntent(turnOn: true);
    }

    if (_matchesAny(text, [
      'turn off camera',
      'disable camera',
      'camera off',
    ])) {
      return const SetCameraIntent(turnOn: false);
    }

    if (_matchesAny(text, [
      'switch camera',
      'flip camera',
      'front camera',
      'back camera',
    ])) {
      return const SwitchCameraIntent();
    }

    if (_matchesAny(text, [
      'show map',
      'hospital map',
      'map view',
      'show hospitals on map',
    ])) {
      return const ShowHospitalsOnMapIntent();
    }

    if (_matchesAny(text, [
      'find hospital',
      'nearby hospital',
      'hospitals near me',
      'find a hospital',
    ])) {
      return const FindNearbyHospitalsIntent();
    }

    if (_matchesAny(text, [
      'list of doctors',
      'show doctors',
      'available doctors',
      'open doctors',
    ])) {
      return const OpenDoctorListIntent();
    }

    if (_matchesAny(text, [
      'my appointments',
      'show appointments',
      'appointment list',
      'upcoming appointments',
    ])) {
      return const NavigateToAppointmentsIntent();
    }

    if (_matchesAny(text, ['my profile', 'open profile', 'show profile'])) {
      return const NavigateToProfileIntent();
    }

    if (_matchesAny(text, [
      'symptom checker',
      'check my symptoms',
      'check symptoms',
    ])) {
      return const NavigateToSymptomCheckerIntent();
    }

    if (_matchesAny(text, [
      'health progress',
      'my progress',
      'show my progress',
    ])) {
      return const NavigateToHealthProgressIntent();
    }

    final callMatch = RegExp(r'call\s+(?:doctor\s+)?(.+)').firstMatch(text);
    if (callMatch != null &&
        _matchesAny(text, [
          'call doctor',
          'video call',
          'talk to doctor',
          'call ',
        ])) {
      final name = callMatch.group(1)?.trim();
      return StartVideoCallIntent(
        doctorName: (name == null || name.isEmpty) ? null : name,
      );
    }

    if (_matchesAny(text, ['repeat', 'say again', 'what did you say'])) {
      return const RepeatLastResponseIntent();
    }

    if (_matchesAny(text, ['what can i say', 'voice commands', 'help'])) {
      return const ShowVoiceCommandsHelpIntent();
    }

    if (_matchesAny(text, ['home', 'go home', 'main screen', 'dashboard'])) {
      return const NavigateHomeIntent();
    }

    return UnknownIntent(params);
  }

  bool _matchesAny(String text, List<String> phrases) {
    return phrases.any(text.contains);
  }
}
