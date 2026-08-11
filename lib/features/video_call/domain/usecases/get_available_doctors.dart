import 'package:ehealth/core/result/result.dart';
import 'package:ehealth/core/usecase/usecase.dart';
import 'package:ehealth/features/video_call/domain/entities/doctor.dart';
import 'package:ehealth/features/video_call/domain/repositories/video_call_repository.dart';

class GetAvailableDoctors implements UseCase<List<Doctor>, NoParams> {
  const GetAvailableDoctors(this._repository);

  final VideoCallRepository _repository;

  @override
  Future<Result<List<Doctor>>> call(NoParams params) => _repository.getAvailableDoctors();
}
