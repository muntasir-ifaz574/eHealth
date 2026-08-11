import 'package:ehealth/core/result/result.dart';
import 'package:ehealth/core/usecase/usecase.dart';
import 'package:ehealth/features/hospital/domain/entities/hospital.dart';
import 'package:ehealth/features/hospital/domain/repositories/hospital_repository.dart';
import 'package:equatable/equatable.dart';

class GetNearbyHospitalsParams extends Equatable {
  const GetNearbyHospitalsParams({
    required this.latitude,
    required this.longitude,
    this.radiusMeters = 5000,
  });

  final double latitude;
  final double longitude;
  final int radiusMeters;

  @override
  List<Object?> get props => [latitude, longitude, radiusMeters];
}

class GetNearbyHospitals implements UseCase<List<Hospital>, GetNearbyHospitalsParams> {
  const GetNearbyHospitals(this._repository);

  final HospitalRepository _repository;

  @override
  Future<Result<List<Hospital>>> call(GetNearbyHospitalsParams params) {
    return _repository.getNearbyHospitals(
      latitude: params.latitude,
      longitude: params.longitude,
      radiusMeters: params.radiusMeters,
    );
  }
}
