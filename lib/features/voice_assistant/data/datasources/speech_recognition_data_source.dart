import 'package:ehealth/core/error/exceptions.dart';
import 'package:ehealth/features/voice_assistant/domain/entities/voice_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Thin wrapper over the `speech_to_text` plugin.
class SpeechRecognitionDataSource {
  SpeechRecognitionDataSource({SpeechToText? speechToText})
    : _speech = speechToText ?? SpeechToText();

  final SpeechToText _speech;
  void Function()? onListeningStopped;
  void Function(String message, bool permanent)? onErrorOccurred;

  bool get isListening => _speech.isListening;

  Future<bool> initialize() {
    return _speech.initialize(
      onError: (error) =>
          onErrorOccurred?.call(error.errorMsg, error.permanent),
      onStatus: (status) {
        if (status == SpeechToText.doneStatus ||
            status == SpeechToText.notListeningStatus) {
          onListeningStopped?.call();
        }
      },
    );
  }

  Future<void> startListening({
    required void Function(VoiceRecognitionResult result) onResult,
  }) async {
    final available = _speech.isAvailable ? true : await initialize();
    if (!available) {
      throw const PermissionException(
        'Microphone / speech recognition permission denied.',
      );
    }

    await _speech.listen(
      onResult: (recognitionResult) {
        onResult(
          VoiceRecognitionResult(
            text: recognitionResult.recognizedWords,
            isFinal: recognitionResult.finalResult,
            confidence: recognitionResult.confidence,
          ),
        );
      },
      listenOptions: SpeechListenOptions(
        partialResults: true,
        cancelOnError: true,
      ),
    );
  }

  Future<void> stopListening() => _speech.stop();
}
