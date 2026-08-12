import 'package:collection/collection.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:ehealth/core/error/failures.dart';
import 'package:ehealth/core/network/api_error_mapper.dart';
import 'package:ehealth/core/result/result.dart';
import 'package:ehealth/features/video_call/data/datasources/doctor_remote_data_source.dart';
import 'package:ehealth/features/video_call/domain/entities/conference_credentials.dart';
import 'package:ehealth/features/video_call/domain/entities/doctor.dart';
import 'package:ehealth/features/video_call/domain/repositories/video_call_repository.dart';

class VideoCallRepositoryImpl implements VideoCallRepository {
  const VideoCallRepositoryImpl(this._doctorDataSource);

  final DoctorRemoteDataSource _doctorDataSource;

  @override
  Future<Result<List<Doctor>>> getAvailableDoctors() async {
    try {
      return Right(await _doctorDataSource.fetchAvailableDoctors());
    } on DioException catch (e) {
      return Left(mapDioException(e));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Result<Doctor>> getDoctorById(int doctorId) async {
    try {
      final doctors = await _doctorDataSource.fetchAvailableDoctors();
      final doctor = doctors.where((d) => d.doctorId == doctorId).firstOrNull;
      if (doctor == null) return const Left(ServerFailure('Doctor not found.'));
      return Right(doctor);
    } on DioException catch (e) {
      return Left(mapDioException(e));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Result<ConferenceCredentials>> getConferenceCredentials(String consultationId) async {
    try {
      return Right(await _doctorDataSource.fetchConferenceCredentials(consultationId));
    } on DioException catch (e) {
      return Left(mapDioException(e));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }
}
