import 'package:ehealth/features/hospital/domain/entities/hospital.dart';

class HospitalModel extends Hospital {
  const HospitalModel({
    required super.placeId,
    required super.name,
    required super.address,
    required super.latitude,
    required super.longitude,
    super.phoneNumber,
    super.rating,
    super.isOpenNow,
    super.distanceInMeters,
  });

  factory HospitalModel.fromNearbySearchJson(Map<String, dynamic> json) {
    final geometry = json['geometry'] as Map<String, dynamic>?;
    final location = geometry?['location'] as Map<String, dynamic>?;
    final openingHours = json['opening_hours'] as Map<String, dynamic>?;

    return HospitalModel(
      placeId: json['place_id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown hospital',
      address:
          json['vicinity'] as String? ??
          json['formatted_address'] as String? ??
          '',
      latitude: (location?['lat'] as num?)?.toDouble() ?? 0,
      longitude: (location?['lng'] as num?)?.toDouble() ?? 0,
      rating: (json['rating'] as num?)?.toDouble(),
      isOpenNow: openingHours?['open_now'] as bool?,
    );
  }

  factory HospitalModel.fromDetailsJson(Map<String, dynamic> json) {
    final geometry = json['geometry'] as Map<String, dynamic>?;
    final location = geometry?['location'] as Map<String, dynamic>?;

    return HospitalModel(
      placeId: json['place_id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown hospital',
      address: json['formatted_address'] as String? ?? '',
      latitude: (location?['lat'] as num?)?.toDouble() ?? 0,
      longitude: (location?['lng'] as num?)?.toDouble() ?? 0,
      phoneNumber:
          json['international_phone_number'] as String? ??
          json['formatted_phone_number'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
    );
  }
}
