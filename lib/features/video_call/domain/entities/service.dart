import 'package:equatable/equatable.dart';

class Service extends Equatable {
  const Service({
    required this.serviceId,
    required this.serviceName,
    required this.costPerHour,
    required this.durationHours,
    required this.totalCost,
    required this.isActive,
    required this.doctorId,
  });

  final int serviceId;
  final String serviceName;
  final num costPerHour;
  final num durationHours;
  final num totalCost;
  final bool isActive;
  final int doctorId;

  @override
  List<Object?> get props =>
      [serviceId, serviceName, costPerHour, durationHours, totalCost, isActive, doctorId];
}
