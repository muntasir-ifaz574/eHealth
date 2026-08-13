import 'package:ehealth/core/usecase/usecase.dart';
import 'package:ehealth/features/voice_assistant/domain/entities/voice_recognition_result.dart';
import 'package:ehealth/features/voice_assistant/presentation/providers/voice_assistant_providers.dart';
import 'package:ehealth/features/voice_assistant/presentation/providers/voice_assistant_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final voiceAssistantControllerProvider =
    NotifierProvider<VoiceAssistantController, VoiceAssistantState>(
      VoiceAssistantController.new,
    );

class VoiceAssistantController extends Notifier<VoiceAssistantState> {
  bool _continuousMode = false;

  @override
  VoiceAssistantState build() {
    ref
        .read(voiceRepositoryProvider)
        .setEngineListeners(
          onListeningStopped: _onEngineListeningStopped,
          onError: _onEngineError,
        );
    return const VoiceAssistantState();
  }

  Future<void> toggleListening() async {
    if (_continuousMode || state.isListening) {
      await stopListening();
    } else {
      _continuousMode = true;
      await startListening();
    }
  }

  Future<void> startListening() async {
    state = state.copyWith(
      status: VoiceStatus.initializing,
      clearError: true,
      transcript: '',
    );

    final initResult = await ref
        .read(initializeVoiceEngineProvider)
        .call(const NoParams());
    final canListen = initResult.fold((_) => false, (available) => available);
    if (!canListen) {
      _continuousMode = false;
      state = state.copyWith(
        status: VoiceStatus.error,
        errorMessage:
            'Voice recognition is not available. Check microphone permission.',
      );
      return;
    }

    final result = await ref.read(startListeningProvider).call(_onResult);
    result.fold((failure) {
      _continuousMode = false;
      state = state.copyWith(
        status: VoiceStatus.error,
        errorMessage: failure.message,
      );
    }, (_) => state = state.copyWith(status: VoiceStatus.listening));
  }

  Future<void> stopListening() async {
    _continuousMode = false;
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

  void _onEngineListeningStopped() {
    if (state.status != VoiceStatus.listening) return;
    if (_continuousMode) {
      startListening();
    } else {
      state = state.copyWith(status: VoiceStatus.idle);
    }
  }

  void _onEngineError(String message, bool permanent) {
    if (state.status != VoiceStatus.listening &&
        state.status != VoiceStatus.initializing) {
      return;
    }
    if (_continuousMode && !permanent) {
      startListening();
      return;
    }
    _continuousMode = false;
    state = state.copyWith(
      status: VoiceStatus.error,
      errorMessage: 'Voice recognition error: $message',
    );
  }

  Future<void> speak(String message) async {
    state = state.copyWith(status: VoiceStatus.speaking, lastResponse: message);
    await ref.read(speakResponseProvider).call(message);
    if (state.status == VoiceStatus.speaking) {
      state = state.copyWith(status: VoiceStatus.idle);
    }
    if (_continuousMode) await startListening();
  }
}
