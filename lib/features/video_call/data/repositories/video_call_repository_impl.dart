import 'package:dartz/dartz.dart';
import 'package:ehealth/core/error/failures.dart';
import 'package:ehealth/core/result/result.dart';
import 'package:ehealth/features/video_call/data/datasources/doctor_local_data_source.dart';
import 'package:ehealth/features/video_call/domain/entities/call_session.dart';
import 'package:ehealth/features/video_call/domain/entities/doctor.dart';
import 'package:ehealth/features/video_call/domain/repositories/video_call_repository.dart';

class VideoCallRepositoryImpl implements VideoCallRepository {
  const VideoCallRepositoryImpl(this._doctorDataSource);

  final DoctorLocalDataSource _doctorDataSource;

  @override
  Future<Result<List<Doctor>>> getAvailableDoctors() async {
    try {
      return Right(await _doctorDataSource.fetchAvailableDoctors());
    } catch (_) {
      return const Left(ServerFailure('Unable to load doctors right now.'));
    }
  }

  @override
  Future<Result<Doctor>> getDoctorById(String doctorId) async {
    final doctor = await _doctorDataSource.fetchDoctorById(doctorId);
    if (doctor == null) return const Left(ServerFailure('Doctor not found.'));
    return Right(doctor);
  }

  @override
  Future<Result<CallSession>> createCallSession({
    required Doctor doctor,
    required String callerUserId,
    required String callerUserName,
  }) async {
    if (!doctor.isOnline) {
      return Left(CallFailure('${doctor.name} is currently offline.'));
    }

    return Right(
      CallSession(
        callId: 'call_${doctor.id}_$callerUserId',
        doctorId: doctor.id,
        doctorName: doctor.name,
        callerUserId: callerUserId,
        callerUserName: callerUserName,
      ),
    );
  }
}
