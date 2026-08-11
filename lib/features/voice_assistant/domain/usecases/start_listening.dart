import 'package:ehealth/core/result/result.dart';
import 'package:ehealth/features/voice_assistant/domain/entities/voice_recognition_result.dart';
import 'package:ehealth/features/voice_assistant/domain/repositories/voice_repository.dart';

class StartListening {
  const StartListening(this._repository);

  final VoiceRepository _repository;

  Future<Result<void>> call(void Function(VoiceRecognitionResult result) onResult) {
    return _repository.startListening(onResult: onResult);
  }
}
