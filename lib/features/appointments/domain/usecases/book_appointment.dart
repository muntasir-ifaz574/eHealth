import 'package:ehealth/core/result/result.dart';
import 'package:ehealth/core/usecase/usecase.dart';
import 'package:ehealth/features/appointments/domain/entities/booking_confirmation.dart';
import 'package:ehealth/features/appointments/domain/repositories/appointments_repository.dart';
import 'package:equatable/equatable.dart';

class BookAppointmentParams extends Equatable {
  const BookAppointmentParams({
    required this.doctorId,
    this.serviceId,
    required this.startTime,
    this.requestedDurationHours,
  });

  final int doctorId;
  final int? serviceId;
  final DateTime startTime;
  final int? requestedDurationHours;

  @override
  List<Object?> get props => [doctorId, serviceId, startTime, requestedDurationHours];
}

class BookAppointment implements UseCase<BookingConfirmation, BookAppointmentParams> {
  const BookAppointment(this._repository);

  final AppointmentsRepository _repository;

  @override
  Future<Result<BookingConfirmation>> call(BookAppointmentParams params) {
    return _repository.bookAppointment(
      doctorId: params.doctorId,
      serviceId: params.serviceId,
      startTime: params.startTime,
      requestedDurationHours: params.requestedDurationHours,
    );
  }
}
