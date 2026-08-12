import 'package:ehealth/features/video_call/data/models/service_model.dart';
import 'package:ehealth/features/video_call/domain/entities/doctor.dart';

class DoctorModel extends Doctor {
  const DoctorModel({
    required super.doctorId,
    required super.doctorName,
    super.doctorEmail,
    super.specialization,
    super.qualifications,
    super.phoneNumber,
    super.bio,
    super.services,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      doctorId: json['doctorId'] as int,
      doctorName: json['doctorName'] as String,
      doctorEmail: json['doctorEmail'] as String?,
      specialization: json['specialization'] as String?,
      qualifications: json['qualifications'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      bio: json['bio'] as String?,
      services: (json['services'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>()
          .map(ServiceModel.fromJson)
          .toList(),
    );
  }
}
