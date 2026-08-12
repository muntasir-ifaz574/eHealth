import 'package:dio/dio.dart';
import 'package:ehealth/core/constants/api_endpoints.dart';
import 'package:ehealth/features/appointments/data/models/appointment_model.dart';
import 'package:ehealth/features/appointments/data/models/booking_confirmation_model.dart';

abstract interface class AppointmentsRemoteDataSource {
  Future<BookingConfirmationModel> bookAppointment({
    required int doctorId,
    int? serviceId,
    required DateTime startTime,
    int? requestedDurationHours,
  });

  Future<List<AppointmentModel>> fetchMyAppointments();
}

class AppointmentsRemoteDataSourceImpl implements AppointmentsRemoteDataSource {
  AppointmentsRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<BookingConfirmationModel> bookAppointment({
    required int doctorId,
    int? serviceId,
    required DateTime startTime,
    int? requestedDurationHours,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.appointments,
      data: {
        'doctorId': doctorId,
        'serviceId': ?serviceId,
        'startTime': startTime.toUtc().toIso8601String(),
        'requestedDurationHours': ?requestedDurationHours,
      },
    );
    return BookingConfirmationModel.fromJson(response.data!);
  }

  @override
  Future<List<AppointmentModel>> fetchMyAppointments() async {
    final response = await _dio.get<List<dynamic>>(ApiEndpoints.appointments);
    return (response.data ?? [])
        .cast<Map<String, dynamic>>()
        .map(AppointmentModel.fromJson)
        .toList();
  }
}
