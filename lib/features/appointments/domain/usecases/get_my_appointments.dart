import 'package:ehealth/core/result/result.dart';
import 'package:ehealth/core/usecase/usecase.dart';
import 'package:ehealth/features/appointments/domain/entities/appointment.dart';
import 'package:ehealth/features/appointments/domain/repositories/appointments_repository.dart';

class GetMyAppointments implements UseCase<List<Appointment>, NoParams> {
  const GetMyAppointments(this._repository);

  final AppointmentsRepository _repository;

  @override
  Future<Result<List<Appointment>>> call(NoParams params) => _repository.getMyAppointments();
}
