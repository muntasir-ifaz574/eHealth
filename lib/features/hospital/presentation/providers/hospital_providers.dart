import 'package:ehealth/core/di/core_providers.dart';
import 'package:ehealth/features/hospital/data/datasources/hospital_remote_data_source.dart';
import 'package:ehealth/features/hospital/data/repositories/hospital_repository_impl.dart';
import 'package:ehealth/features/hospital/domain/entities/hospital.dart';
import 'package:ehealth/features/hospital/domain/repositories/hospital_repository.dart';
import 'package:ehealth/features/hospital/domain/usecases/get_hospital_details.dart';
import 'package:ehealth/features/hospital/domain/usecases/get_nearby_hospitals.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

final hospitalRemoteDataSourceProvider = Provider<HospitalRemoteDataSource>((ref) {
  return HospitalRemoteDataSourceImpl(ref.watch(dioProvider));
});

final hospitalRepositoryProvider = Provider<HospitalRepository>((ref) {
  return HospitalRepositoryImpl(
    remoteDataSource: ref.watch(hospitalRemoteDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
});

final getNearbyHospitalsProvider = Provider<GetNearbyHospitals>((ref) {
  return GetNearbyHospitals(ref.watch(hospitalRepositoryProvider));
});

final getHospitalDetailsProvider = Provider<GetHospitalDetails>((ref) {
  return GetHospitalDetails(ref.watch(hospitalRepositoryProvider));
});

/// Current device position, requesting permission on first read.
final currentPositionProvider = FutureProvider.autoDispose<Position>((ref) async {
  final permissionGranted = await ref.watch(permissionServiceProvider).requestLocation();
  if (!permissionGranted) {
    throw StateError('Location permission was denied.');
  }
  return Geolocator.getCurrentPosition(
    locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
  );
});

final nearbyHospitalsProvider = FutureProvider.autoDispose<List<Hospital>>((ref) async {
  final position = await ref.watch(currentPositionProvider.future);
  final result = await ref.watch(getNearbyHospitalsProvider).call(
        GetNearbyHospitalsParams(latitude: position.latitude, longitude: position.longitude),
      );
  return result.fold((failure) => throw failure, (hospitals) => hospitals);
});

final hospitalDetailsProvider =
    FutureProvider.autoDispose.family<Hospital, String>((ref, placeId) async {
  final result = await ref.watch(getHospitalDetailsProvider).call(placeId);
  return result.fold((failure) => throw failure, (hospital) => hospital);
});
