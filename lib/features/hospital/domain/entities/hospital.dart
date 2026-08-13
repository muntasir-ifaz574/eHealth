import 'package:equatable/equatable.dart';

class Hospital extends Equatable {
  const Hospital({
    required this.placeId,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.phoneNumber,
    this.rating,
    this.isOpenNow,
    this.distanceInMeters,
  });

  final String placeId;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String? phoneNumber;
  final double? rating;
  final bool? isOpenNow;
  final double? distanceInMeters;

  Hospital copyWith({String? phoneNumber, double? distanceInMeters}) {
    return Hospital(
      placeId: placeId,
      name: name,
      address: address,
      latitude: latitude,
      longitude: longitude,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      rating: rating,
      isOpenNow: isOpenNow,
      distanceInMeters: distanceInMeters ?? this.distanceInMeters,
    );
  }

  @override
  List<Object?> get props => [
    placeId,
    name,
    address,
    latitude,
    longitude,
    phoneNumber,
  ];
}
