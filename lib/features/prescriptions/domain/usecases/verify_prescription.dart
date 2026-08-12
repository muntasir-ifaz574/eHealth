import 'package:ehealth/core/result/result.dart';
import 'package:ehealth/core/usecase/usecase.dart';
import 'package:ehealth/features/prescriptions/domain/entities/prescription_verification.dart';
import 'package:ehealth/features/prescriptions/domain/repositories/prescriptions_repository.dart';
import 'package:equatable/equatable.dart';

class VerifyPrescriptionParams extends Equatable {
  const VerifyPrescriptionParams({required this.prescriptionId, required this.filePath});

  final String prescriptionId;
  final String filePath;

  @override
  List<Object?> get props => [prescriptionId, filePath];
}

class VerifyPrescription implements UseCase<PrescriptionVerification, VerifyPrescriptionParams> {
  const VerifyPrescription(this._repository);

  final PrescriptionsRepository _repository;

  @override
  Future<Result<PrescriptionVerification>> call(VerifyPrescriptionParams params) {
    return _repository.verifyPrescription(
      prescriptionId: params.prescriptionId,
      filePath: params.filePath,
    );
  }
}
