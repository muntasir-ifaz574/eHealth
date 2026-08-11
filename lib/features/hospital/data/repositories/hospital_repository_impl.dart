import 'package:dartz/dartz.dart';
import 'package:ehealth/core/error/exceptions.dart';
import 'package:ehealth/core/error/failures.dart';
import 'package:ehealth/core/network/network_info.dart';
import 'package:ehealth/core/result/result.dart';
import 'package:ehealth/features/hospital/data/datasources/hospital_remote_data_source.dart';
import 'package:ehealth/features/hospital/domain/entities/hospital.dart';
import 'package:ehealth/features/hospital/domain/repositories/hospital_repository.dart';
import 'package:geolocator/geolocator.dart';

class HospitalRepositoryImpl implements HospitalRepository {
  HospitalRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  final HospitalRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  @override
  Future<Result<List<Hospital>>> getNearbyHospitals({
    required double latitude,
    required double longitude,
    int radiusMeters = 5000,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final hospitals = await remoteDataSource.fetchNearbyHospitals(
        latitude: latitude,
        longitude: longitude,
        radiusMeters: radiusMeters,
      );

      final withDistance = hospitals.map((hospital) {
        final distance = Geolocator.distanceBetween(
          latitude,
          longitude,
          hospital.latitude,
          hospital.longitude,
        );
        return hospital.copyWith(distanceInMeters: distance);
      }).toList()
        ..sort((a, b) => (a.distanceInMeters ?? 0).compareTo(b.distanceInMeters ?? 0));

      return Right(withDistance);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Result<Hospital>> getHospitalDetails(String placeId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final hospital = await remoteDataSource.fetchHospitalDetails(placeId);
      return Right(hospital);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }
}
