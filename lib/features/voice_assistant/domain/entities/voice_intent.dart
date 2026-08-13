import 'package:equatable/equatable.dart';

sealed class VoiceIntent extends Equatable {
  const VoiceIntent();

  @override
  List<Object?> get props => [];
}

class NavigateHomeIntent extends VoiceIntent {
  const NavigateHomeIntent();
}

class FindNearbyHospitalsIntent extends VoiceIntent {
  const FindNearbyHospitalsIntent();
}

class ShowHospitalsOnMapIntent extends VoiceIntent {
  const ShowHospitalsOnMapIntent();
}

class CallEmergencyIntent extends VoiceIntent {
  const CallEmergencyIntent();
}

class OpenDoctorListIntent extends VoiceIntent {
  const OpenDoctorListIntent();
}

class StartVideoCallIntent extends VoiceIntent {
  const StartVideoCallIntent({this.doctorName});

  final String? doctorName;

  @override
  List<Object?> get props => [doctorName];
}

class EndCallIntent extends VoiceIntent {
  const EndCallIntent();
}

class SetMicrophoneIntent extends VoiceIntent {
  const SetMicrophoneIntent({required this.turnOn});

  final bool turnOn;

  @override
  List<Object?> get props => [turnOn];
}

class SetCameraIntent extends VoiceIntent {
  const SetCameraIntent({required this.turnOn});

  final bool turnOn;

  @override
  List<Object?> get props => [turnOn];
}

class SwitchCameraIntent extends VoiceIntent {
  const SwitchCameraIntent();
}

class NavigateToAppointmentsIntent extends VoiceIntent {
  const NavigateToAppointmentsIntent();
}

class NavigateToProfileIntent extends VoiceIntent {
  const NavigateToProfileIntent();
}

class NavigateToSymptomCheckerIntent extends VoiceIntent {
  const NavigateToSymptomCheckerIntent();
}

class NavigateToHealthProgressIntent extends VoiceIntent {
  const NavigateToHealthProgressIntent();
}

class ShowVoiceCommandsHelpIntent extends VoiceIntent {
  const ShowVoiceCommandsHelpIntent();
}

class StopListeningIntent extends VoiceIntent {
  const StopListeningIntent();
}

class RepeatLastResponseIntent extends VoiceIntent {
  const RepeatLastResponseIntent();
}

class UnknownIntent extends VoiceIntent {
  const UnknownIntent(this.rawText);

  final String rawText;

  @override
  List<Object?> get props => [rawText];
}
