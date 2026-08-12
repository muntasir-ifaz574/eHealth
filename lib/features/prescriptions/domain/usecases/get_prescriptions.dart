import 'package:ehealth/core/result/result.dart';
import 'package:ehealth/core/usecase/usecase.dart';
import 'package:ehealth/features/prescriptions/domain/entities/prescription.dart';
import 'package:ehealth/features/prescriptions/domain/repositories/prescriptions_repository.dart';

class GetPrescriptions implements UseCase<List<Prescription>, String> {
  const GetPrescriptions(this._repository);

  final PrescriptionsRepository _repository;

  @override
  Future<Result<List<Prescription>>> call(String consultationId) {
    return _repository.getPrescriptions(consultationId);
  }
}
