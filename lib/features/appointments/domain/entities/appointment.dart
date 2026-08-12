import 'package:ehealth/features/video_call/domain/entities/doctor.dart';
import 'package:ehealth/features/video_call/domain/entities/service.dart';
import 'package:equatable/equatable.dart';

/// Mirrors `UsersAppointmentListDTO` — a booked consultation with its
/// doctor and the service that was booked.
class Appointment extends Equatable {
  const Appointment({required this.consultationId, required this.doctor, required this.service});

  final int consultationId;
  final Doctor doctor;
  final Service service;

  @override
  List<Object?> get props => [consultationId, doctor, service];
}
