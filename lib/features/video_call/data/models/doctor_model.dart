import 'package:ehealth/features/video_call/domain/entities/doctor.dart';

class DoctorModel extends Doctor {
  const DoctorModel({
    required super.id,
    required super.name,
    required super.specialty,
    super.isOnline,
    super.avatarUrl,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      id: json['id'] as String,
      name: json['name'] as String,
      specialty: json['specialty'] as String,
      isOnline: json['isOnline'] as bool? ?? false,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }
}
