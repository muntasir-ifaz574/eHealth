import 'package:ehealth/features/video_call/domain/entities/service.dart';
import 'package:equatable/equatable.dart';

class Doctor extends Equatable {
  const Doctor({
    required this.doctorId,
    required this.doctorName,
    this.doctorEmail,
    this.specialization,
    this.qualifications,
    this.phoneNumber,
    this.bio,
    this.services = const [],
  });

  final int doctorId;
  final String doctorName;
  final String? doctorEmail;
  final String? specialization;
  final String? qualifications;
  final String? phoneNumber;
  final String? bio;
  final List<Service> services;

  bool get isBookable => services.any((service) => service.isActive);

  @override
  List<Object?> get props => [
        doctorId,
        doctorName,
        doctorEmail,
        specialization,
        qualifications,
        phoneNumber,
        bio,
        services,
      ];
}
