import 'package:ehealth/features/voice_assistant/domain/entities/voice_intent.dart';
import 'package:equatable/equatable.dart';

enum VoiceStatus { idle, initializing, listening, processing, speaking, error }

class VoiceAssistantState extends Equatable {
  const VoiceAssistantState({
    this.status = VoiceStatus.idle,
    this.transcript = '',
    this.lastResponse,
    this.pendingIntent,
    this.errorMessage,
  });

  final VoiceStatus status;
  final String transcript;
  final String? lastResponse;
  final VoiceIntent? pendingIntent;
  final String? errorMessage;

  bool get isListening => status == VoiceStatus.listening;

  VoiceAssistantState copyWith({
    VoiceStatus? status,
    String? transcript,
    String? lastResponse,
    VoiceIntent? pendingIntent,
    bool clearPendingIntent = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return VoiceAssistantState(
      status: status ?? this.status,
      transcript: transcript ?? this.transcript,
      lastResponse: lastResponse ?? this.lastResponse,
      pendingIntent: clearPendingIntent
          ? null
          : (pendingIntent ?? this.pendingIntent),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    status,
    transcript,
    lastResponse,
    pendingIntent,
    errorMessage,
  ];
}
