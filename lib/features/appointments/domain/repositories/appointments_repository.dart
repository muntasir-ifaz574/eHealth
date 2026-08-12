import 'package:ehealth/core/result/result.dart';
import 'package:ehealth/features/appointments/domain/entities/appointment.dart';
import 'package:ehealth/features/appointments/domain/entities/booking_confirmation.dart';

abstract interface class AppointmentsRepository {
  Future<Result<BookingConfirmation>> bookAppointment({
    required int doctorId,
    int? serviceId,
    required DateTime startTime,
    int? requestedDurationHours,
  });

  Future<Result<List<Appointment>>> getMyAppointments();
}
