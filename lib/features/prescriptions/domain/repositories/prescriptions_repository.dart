import 'package:ehealth/core/result/result.dart';
import 'package:ehealth/features/prescriptions/domain/entities/prescription.dart';
import 'package:ehealth/features/prescriptions/domain/entities/prescription_verification.dart';

abstract interface class PrescriptionsRepository {
  Future<Result<List<Prescription>>> getPrescriptions(String consultationId);

  Future<Result<PrescriptionVerification>> verifyPrescription({
    required String prescriptionId,
    required String filePath,
  });

  Future<Result<String>> resolveLocalFile(Prescription prescription);
}
