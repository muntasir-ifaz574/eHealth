import 'package:ehealth/features/video_call/domain/entities/service.dart';

class ServiceModel extends Service {
  const ServiceModel({
    required super.serviceId,
    required super.serviceName,
    required super.costPerHour,
    required super.durationHours,
    required super.totalCost,
    required super.isActive,
    required super.doctorId,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      serviceId: json['serviceId'] as int,
      serviceName: json['serviceName'] as String,
      costPerHour: _parseNum(json['costPerHour']),
      durationHours: _parseNum(json['durationHours']),
      totalCost: _parseNum(json['totalCost']),
      isActive: json['isActive'] as bool? ?? true,
      doctorId: json['doctorId'] as int,
    );
  }

  static num _parseNum(dynamic value) {
    if (value is num) return value;
    return num.parse(value as String);
  }
}
