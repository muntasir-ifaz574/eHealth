import 'package:ehealth/core/result/result.dart';
import 'package:ehealth/core/usecase/usecase.dart';
import 'package:ehealth/features/voice_assistant/domain/repositories/voice_repository.dart';

class SpeakResponse implements UseCase<void, String> {
  const SpeakResponse(this._repository);

  final VoiceRepository _repository;

  @override
  Future<Result<void>> call(String params) => _repository.speak(params);
}
