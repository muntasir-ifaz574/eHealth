import 'package:ehealth/core/result/result.dart';
import 'package:ehealth/features/voice_assistant/domain/entities/voice_recognition_result.dart';

abstract interface class VoiceRepository {
  Future<Result<bool>> initialize();

  bool get isListening;

  Future<Result<void>> startListening({
    required void Function(VoiceRecognitionResult result) onResult,
  });

  Future<Result<void>> stopListening();

  Future<Result<void>> speak(String message);

  void setEngineListeners({
    void Function()? onListeningStopped,
    void Function(String message, bool permanent)? onError,
  });
}
