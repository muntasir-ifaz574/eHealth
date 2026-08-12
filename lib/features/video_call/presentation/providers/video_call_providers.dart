import 'package:ehealth/core/di/core_providers.dart';
import 'package:ehealth/core/usecase/usecase.dart';
import 'package:ehealth/features/video_call/data/datasources/doctor_remote_data_source.dart';
import 'package:ehealth/features/video_call/data/repositories/video_call_repository_impl.dart';
import 'package:ehealth/features/video_call/domain/entities/conference_credentials.dart';
import 'package:ehealth/features/video_call/domain/entities/doctor.dart';
import 'package:ehealth/features/video_call/domain/repositories/video_call_repository.dart';
import 'package:ehealth/features/video_call/domain/usecases/get_available_doctors.dart';
import 'package:ehealth/features/video_call/domain/usecases/get_conference_credentials.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final doctorRemoteDataSourceProvider = Provider<DoctorRemoteDataSource>((ref) {
  return DoctorRemoteDataSourceImpl(ref.watch(dioProvider));
});

final videoCallRepositoryProvider = Provider<VideoCallRepository>((ref) {
  return VideoCallRepositoryImpl(ref.watch(doctorRemoteDataSourceProvider));
});

final getAvailableDoctorsProvider = Provider<GetAvailableDoctors>((ref) {
  return GetAvailableDoctors(ref.watch(videoCallRepositoryProvider));
});

final getConferenceCredentialsProvider = Provider<GetConferenceCredentials>((ref) {
  return GetConferenceCredentials(ref.watch(videoCallRepositoryProvider));
});

final availableDoctorsProvider = FutureProvider.autoDispose<List<Doctor>>((ref) async {
  final result = await ref.watch(getAvailableDoctorsProvider).call(const NoParams());
  return result.fold((failure) => throw failure, (doctors) => doctors);
});

final doctorByIdProvider = FutureProvider.autoDispose.family<Doctor, int>((ref, doctorId) async {
  final result = await ref.watch(videoCallRepositoryProvider).getDoctorById(doctorId);
  return result.fold((failure) => throw failure, (doctor) => doctor);
});

final conferenceCredentialsProvider =
    FutureProvider.autoDispose.family<ConferenceCredentials, String>((ref, consultationId) async {
  final result = await ref.watch(getConferenceCredentialsProvider).call(consultationId);
  return result.fold((failure) => throw failure, (credentials) => credentials);
});
