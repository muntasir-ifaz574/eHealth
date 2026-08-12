import 'package:ehealth/core/di/core_providers.dart';
import 'package:ehealth/features/prescriptions/data/datasources/prescription_file_data_source.dart';
import 'package:ehealth/features/prescriptions/data/datasources/prescriptions_remote_data_source.dart';
import 'package:ehealth/features/prescriptions/data/repositories/prescriptions_repository_impl.dart';
import 'package:ehealth/features/prescriptions/domain/entities/prescription.dart';
import 'package:ehealth/features/prescriptions/domain/repositories/prescriptions_repository.dart';
import 'package:ehealth/features/prescriptions/domain/usecases/get_local_prescription_file.dart';
import 'package:ehealth/features/prescriptions/domain/usecases/get_prescriptions.dart';
import 'package:ehealth/features/prescriptions/domain/usecases/verify_prescription.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final prescriptionsRemoteDataSourceProvider = Provider<PrescriptionsRemoteDataSource>((ref) {
  return PrescriptionsRemoteDataSourceImpl(ref.watch(dioProvider));
});

final prescriptionFileDataSourceProvider = Provider<PrescriptionFileDataSource>((ref) {
  return PrescriptionFileDataSourceImpl(ref.watch(dioProvider));
});

final prescriptionsRepositoryProvider = Provider<PrescriptionsRepository>((ref) {
  return PrescriptionsRepositoryImpl(
    ref.watch(prescriptionsRemoteDataSourceProvider),
    ref.watch(prescriptionFileDataSourceProvider),
  );
});

final getPrescriptionsProvider = Provider<GetPrescriptions>((ref) {
  return GetPrescriptions(ref.watch(prescriptionsRepositoryProvider));
});

final verifyPrescriptionProvider = Provider<VerifyPrescription>((ref) {
  return VerifyPrescription(ref.watch(prescriptionsRepositoryProvider));
});

final getLocalPrescriptionFileProvider = Provider<GetLocalPrescriptionFile>((ref) {
  return GetLocalPrescriptionFile(ref.watch(prescriptionsRepositoryProvider));
});

final prescriptionsForConsultationProvider =
    FutureProvider.autoDispose.family<List<Prescription>, String>((ref, consultationId) async {
  final result = await ref.watch(getPrescriptionsProvider).call(consultationId);
  return result.fold((failure) => throw failure, (prescriptions) => prescriptions);
});
