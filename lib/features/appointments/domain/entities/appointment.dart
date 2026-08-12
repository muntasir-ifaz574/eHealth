import 'package:ehealth/features/video_call/domain/entities/doctor.dart';
import 'package:ehealth/features/video_call/domain/entities/service.dart';
import 'package:equatable/equatable.dart';

class Appointment extends Equatable {
  const Appointment({
    required this.consultationId,
    required this.doctor,
    required this.service,
    this.startTime,
    this.endTime,
  });

  final int consultationId;
  final Doctor doctor;
  final Service service;
  final DateTime? startTime;
  final DateTime? endTime;

  @override
  List<Object?> get props => [
    consultationId,
    doctor,
    service,
    startTime,
    endTime,
  ];
}
