import 'package:ehealth/features/prescriptions/domain/entities/prescription.dart';

class PrescriptionModel extends Prescription {
  const PrescriptionModel({
    required super.prescriptionId,
    required super.consultationId,
    required super.fileRef,
    required super.fileName,
    required super.createdAt,
    required super.updatedAt,
  });

  factory PrescriptionModel.fromJson(Map<String, dynamic> json) {
    final dateInfo = json['dateInfo'] as Map<String, dynamic>;
    return PrescriptionModel(
      prescriptionId: json['prescriptionId'] as int,
      consultationId: json['consultationId'] as int,
      fileRef: json['fileRef'] as String,
      fileName: json['fileName'] as String,
      createdAt: DateTime.parse(dateInfo['createdAt'] as String),
      updatedAt: DateTime.parse(dateInfo['updatedAt'] as String),
    );
  }
}
