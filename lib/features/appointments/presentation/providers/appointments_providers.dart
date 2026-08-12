import 'package:ehealth/core/di/core_providers.dart';
import 'package:ehealth/core/usecase/usecase.dart';
import 'package:ehealth/features/appointments/data/datasources/appointments_remote_data_source.dart';
import 'package:ehealth/features/appointments/data/repositories/appointments_repository_impl.dart';
import 'package:ehealth/features/appointments/domain/entities/appointment.dart';
import 'package:ehealth/features/appointments/domain/repositories/appointments_repository.dart';
import 'package:ehealth/features/appointments/domain/usecases/book_appointment.dart';
import 'package:ehealth/features/appointments/domain/usecases/get_my_appointments.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appointmentsRemoteDataSourceProvider = Provider<AppointmentsRemoteDataSource>((ref) {
  return AppointmentsRemoteDataSourceImpl(ref.watch(dioProvider));
});

final appointmentsRepositoryProvider = Provider<AppointmentsRepository>((ref) {
  return AppointmentsRepositoryImpl(ref.watch(appointmentsRemoteDataSourceProvider));
});

final bookAppointmentProvider = Provider<BookAppointment>((ref) {
  return BookAppointment(ref.watch(appointmentsRepositoryProvider));
});

final getMyAppointmentsProvider = Provider<GetMyAppointments>((ref) {
  return GetMyAppointments(ref.watch(appointmentsRepositoryProvider));
});

final myAppointmentsProvider = FutureProvider.autoDispose<List<Appointment>>((ref) async {
  final result = await ref.watch(getMyAppointmentsProvider).call(const NoParams());
  return result.fold((failure) => throw failure, (appointments) => appointments);
});
