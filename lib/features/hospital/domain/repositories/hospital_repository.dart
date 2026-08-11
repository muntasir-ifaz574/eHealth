import 'package:ehealth/core/result/result.dart';
import 'package:ehealth/features/hospital/domain/entities/hospital.dart';

abstract interface class HospitalRepository {
  Future<Result<List<Hospital>>> getNearbyHospitals({
    required double latitude,
    required double longitude,
    int radiusMeters,
  });

  /// Fetches full details (notably the phone number) for a single hospital.
  Future<Result<Hospital>> getHospitalDetails(String placeId);
}
