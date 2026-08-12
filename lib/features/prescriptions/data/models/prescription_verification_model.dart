import 'package:ehealth/features/prescriptions/domain/entities/prescription_verification.dart';

class PrescriptionVerificationModel extends PrescriptionVerification {
  const PrescriptionVerificationModel({
    required super.isDbMatch,
    required super.isBlockchainMatch,
    required super.fileHash,
    required super.storedHash,
    super.blockchainTxHash,
    super.blockchainId,
  });

  factory PrescriptionVerificationModel.fromJson(Map<String, dynamic> json) {
    return PrescriptionVerificationModel(
      isDbMatch: json['isDbMatch'] as bool,
      isBlockchainMatch: json['isBlockchainMatch'] as bool,
      fileHash: json['fileHash'] as String,
      storedHash: json['storedHash'] as String,
      blockchainTxHash: json['blockchainTxHash'] as String?,
      blockchainId: json['blockchainId'] as int?,
    );
  }
}
