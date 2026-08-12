import 'package:ehealth/features/appointments/domain/entities/appointment.dart';
import 'package:ehealth/features/video_call/data/models/doctor_model.dart';
import 'package:ehealth/features/video_call/data/models/service_model.dart';

class AppointmentModel extends Appointment {
  const AppointmentModel({
    required super.consultationId,
    required super.doctor,
    required super.service,
    super.startTime,
    super.endTime,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    final startRaw = json['startTime'] as String?;
    final endRaw = json['endTime'] as String?;
    return AppointmentModel(
      consultationId: json['consultationId'] as int,
      doctor: DoctorModel.fromJson(json['doctor'] as Map<String, dynamic>),
      service: ServiceModel.fromJson(json['service'] as Map<String, dynamic>),
      startTime: startRaw != null ? DateTime.tryParse(startRaw) : null,
      endTime: endRaw != null ? DateTime.tryParse(endRaw) : null,
    );
  }
}
