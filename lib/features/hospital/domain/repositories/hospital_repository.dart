import 'package:ehealth/core/result/result.dart';
import 'package:ehealth/features/hospital/domain/entities/hospital.dart';

abstract interface class HospitalRepository {
  Future<Result<List<Hospital>>> getNearbyHospitals({
    required double latitude,
    required double longitude,
    int radiusMeters,
  });

  Future<Result<Hospital>> getHospitalDetails(String placeId);
}
