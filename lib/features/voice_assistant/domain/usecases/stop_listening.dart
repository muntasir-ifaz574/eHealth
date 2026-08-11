import 'package:ehealth/core/result/result.dart';
import 'package:ehealth/core/usecase/usecase.dart';
import 'package:ehealth/features/voice_assistant/domain/repositories/voice_repository.dart';

class StopListening implements UseCase<void, NoParams> {
  const StopListening(this._repository);

  final VoiceRepository _repository;

  @override
  Future<Result<void>> call(NoParams params) => _repository.stopListening();
}
