import 'package:ehealth/core/result/result.dart';
import 'package:ehealth/core/usecase/usecase.dart';
import 'package:ehealth/features/voice_assistant/domain/repositories/voice_repository.dart';

class InitializeVoiceEngine implements UseCase<bool, NoParams> {
  const InitializeVoiceEngine(this._repository);

  final VoiceRepository _repository;

  @override
  Future<Result<bool>> call(NoParams params) => _repository.initialize();
}
