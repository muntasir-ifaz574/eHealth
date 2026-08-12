import 'package:ehealth/core/result/result.dart';
import 'package:ehealth/core/usecase/usecase.dart';
import 'package:ehealth/features/video_call/domain/entities/conference_credentials.dart';
import 'package:ehealth/features/video_call/domain/repositories/video_call_repository.dart';

class GetConferenceCredentials implements UseCase<ConferenceCredentials, String> {
  const GetConferenceCredentials(this._repository);

  final VideoCallRepository _repository;

  @override
  Future<Result<ConferenceCredentials>> call(String consultationId) {
    return _repository.getConferenceCredentials(consultationId);
  }
}
