import 'package:equatable/equatable.dart';

class Prescription extends Equatable {
  const Prescription({
    required this.prescriptionId,
    required this.consultationId,
    required this.fileRef,
    required this.fileName,
    this.createdAt,
    this.updatedAt,
  });

  final int prescriptionId;
  final int consultationId;
  final String fileRef;
  final String fileName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  @override
  List<Object?> get props => [
    prescriptionId,
    consultationId,
    fileRef,
    fileName,
    createdAt,
    updatedAt,
  ];
}
