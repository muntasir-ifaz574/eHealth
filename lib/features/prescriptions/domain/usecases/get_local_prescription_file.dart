import 'package:ehealth/core/result/result.dart';
import 'package:ehealth/core/usecase/usecase.dart';
import 'package:ehealth/features/prescriptions/domain/entities/prescription.dart';
import 'package:ehealth/features/prescriptions/domain/repositories/prescriptions_repository.dart';

class GetLocalPrescriptionFile implements UseCase<String, Prescription> {
  const GetLocalPrescriptionFile(this._repository);

  final PrescriptionsRepository _repository;

  @override
  Future<Result<String>> call(Prescription params) => _repository.resolveLocalFile(params);
}
