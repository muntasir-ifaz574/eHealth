import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:ehealth/core/error/failures.dart';
import 'package:ehealth/core/network/api_error_mapper.dart';
import 'package:ehealth/core/result/result.dart';
import 'package:ehealth/features/appointments/data/datasources/appointments_remote_data_source.dart';
import 'package:ehealth/features/appointments/domain/entities/appointment.dart';
import 'package:ehealth/features/appointments/domain/entities/booking_confirmation.dart';
import 'package:ehealth/features/appointments/domain/repositories/appointments_repository.dart';

class AppointmentsRepositoryImpl implements AppointmentsRepository {
  const AppointmentsRepositoryImpl(this._remoteDataSource);

  final AppointmentsRemoteDataSource _remoteDataSource;

  @override
  Future<Result<BookingConfirmation>> bookAppointment({
    required int doctorId,
    int? serviceId,
    required DateTime startTime,
    int? requestedDurationHours,
  }) async {
    try {
      final confirmation = await _remoteDataSource.bookAppointment(
        doctorId: doctorId,
        serviceId: serviceId,
        startTime: startTime,
        requestedDurationHours: requestedDurationHours,
      );
      return Right(confirmation);
    } on DioException catch (e) {
      return Left(mapDioException(e));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Result<List<Appointment>>> getMyAppointments() async {
    try {
      return Right(await _remoteDataSource.fetchMyAppointments());
    } on DioException catch (e) {
      return Left(mapDioException(e));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }
}
