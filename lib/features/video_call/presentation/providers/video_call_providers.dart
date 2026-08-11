import 'package:ehealth/core/di/core_providers.dart';
import 'package:ehealth/core/usecase/usecase.dart';
import 'package:ehealth/features/video_call/data/datasources/doctor_local_data_source.dart';
import 'package:ehealth/features/video_call/data/repositories/video_call_repository_impl.dart';
import 'package:ehealth/features/video_call/domain/entities/call_session.dart';
import 'package:ehealth/features/video_call/domain/entities/doctor.dart';
import 'package:ehealth/features/video_call/domain/repositories/video_call_repository.dart';
import 'package:ehealth/features/video_call/domain/usecases/create_call_session.dart';
import 'package:ehealth/features/video_call/domain/usecases/get_available_doctors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final doctorLocalDataSourceProvider = Provider<DoctorLocalDataSource>((ref) {
  return const DoctorLocalDataSource();
});

final videoCallRepositoryProvider = Provider<VideoCallRepository>((ref) {
  return VideoCallRepositoryImpl(ref.watch(doctorLocalDataSourceProvider));
});

final getAvailableDoctorsProvider = Provider<GetAvailableDoctors>((ref) {
  return GetAvailableDoctors(ref.watch(videoCallRepositoryProvider));
});

final createCallSessionProvider = Provider<CreateCallSession>((ref) {
  return CreateCallSession(ref.watch(videoCallRepositoryProvider));
});

final availableDoctorsProvider = FutureProvider.autoDispose<List<Doctor>>((ref) async {
  final result = await ref.watch(getAvailableDoctorsProvider).call(const NoParams());
  return result.fold((failure) => throw failure, (doctors) => doctors);
});

/// Stable per-install identity for the caller, used as the ZEGOCLOUD user id.
final currentPatientProvider = Provider<({String id, String name})>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  var id = prefs.getString('patient_user_id');
  if (id == null) {
    id = 'patient_${DateTime.now().millisecondsSinceEpoch}';
    prefs.setString('patient_user_id', id);
  }
  return (id: id, name: prefs.getString('patient_name') ?? 'Patient');
});

final doctorByIdProvider = FutureProvider.autoDispose.family<Doctor, String>((ref, doctorId) async {
  final result = await ref.watch(videoCallRepositoryProvider).getDoctorById(doctorId);
  return result.fold((failure) => throw failure, (doctor) => doctor);
});

final callSessionProvider =
    FutureProvider.autoDispose.family<CallSession, String>((ref, doctorId) async {
  final doctor = await ref.watch(doctorByIdProvider(doctorId).future);
  final patient = ref.watch(currentPatientProvider);
  final result = await ref.watch(createCallSessionProvider).call(
        CreateCallSessionParams(
          doctor: doctor,
          callerUserId: patient.id,
          callerUserName: patient.name,
        ),
      );
  return result.fold((failure) => throw failure, (session) => session);
});
