import 'package:ehealth/core/usecase/usecase.dart';
import 'package:ehealth/features/voice_assistant/domain/entities/voice_recognition_result.dart';
import 'package:ehealth/features/voice_assistant/presentation/providers/voice_assistant_providers.dart';
import 'package:ehealth/features/voice_assistant/presentation/providers/voice_assistant_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final voiceAssistantControllerProvider =
    NotifierProvider<VoiceAssistantController, VoiceAssistantState>(VoiceAssistantController.new);

/// Owns the voice-assistant lifecycle: initializing the speech engine,
/// starting/stopping listening, interpreting recognized speech into a
/// [VoiceIntent] and exposing it as `pendingIntent` for the UI layer
/// (`VoiceCommandListener`) to act on — e.g. navigating with go_router or
/// triggering another feature's use case.
class VoiceAssistantController extends Notifier<VoiceAssistantState> {
  @override
  VoiceAssistantState build() => const VoiceAssistantState();

  Future<void> toggleListening() async {
    if (state.isListening) {
      await stopListening();
    } else {
      await startListening();
    }
  }

  Future<void> startListening() async {
    state = state.copyWith(status: VoiceStatus.initializing, clearError: true, transcript: '');

    final initResult = await ref.read(initializeVoiceEngineProvider).call(const NoParams());
    final canListen = initResult.fold((_) => false, (available) => available);
    if (!canListen) {
      state = state.copyWith(
        status: VoiceStatus.error,
        errorMessage: 'Voice recognition is not available. Check microphone permission.',
      );
      return;
    }

    final result = await ref.read(startListeningProvider).call(_onResult);
    result.fold(
      (failure) => state = state.copyWith(status: VoiceStatus.error, errorMessage: failure.message),
      (_) => state = state.copyWith(status: VoiceStatus.listening),
    );
  }

  Future<void> stopListening() async {
    await ref.read(stopListeningProvider).call(const NoParams());
    state = state.copyWith(status: VoiceStatus.idle);
  }

  void _onResult(VoiceRecognitionResult result) {
    state = state.copyWith(transcript: result.text);
    if (!result.isFinal || result.text.trim().isEmpty) return;

    state = state.copyWith(status: VoiceStatus.processing);
    final intent = ref.read(interpretVoiceCommandProvider).call(result.text);
    state = state.copyWith(status: VoiceStatus.idle, pendingIntent: intent);
  }

  /// Called by [VoiceCommandListener] right after it has acted on
  /// `state.pendingIntent`, so the same command doesn't re-fire on rebuild.
  void clearPendingIntent() {
    state = state.copyWith(clearPendingIntent: true);
  }

  Future<void> speak(String message) async {
    state = state.copyWith(status: VoiceStatus.speaking, lastResponse: message);
    await ref.read(speakResponseProvider).call(message);
    if (state.status == VoiceStatus.speaking) {
      state = state.copyWith(status: VoiceStatus.idle);
    }
  }
}
