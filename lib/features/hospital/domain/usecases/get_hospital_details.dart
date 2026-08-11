import 'package:ehealth/core/result/result.dart';
import 'package:ehealth/core/usecase/usecase.dart';
import 'package:ehealth/features/hospital/domain/entities/hospital.dart';
import 'package:ehealth/features/hospital/domain/repositories/hospital_repository.dart';

class GetHospitalDetails implements UseCase<Hospital, String> {
  const GetHospitalDetails(this._repository);

  final HospitalRepository _repository;

  @override
  Future<Result<Hospital>> call(String placeId) => _repository.getHospitalDetails(placeId);
}
