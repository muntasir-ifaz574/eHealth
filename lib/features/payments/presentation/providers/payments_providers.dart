import 'package:ehealth/core/di/core_providers.dart';
import 'package:ehealth/features/payments/data/datasources/payments_remote_data_source.dart';
import 'package:ehealth/features/payments/data/repositories/payments_repository_impl.dart';
import 'package:ehealth/features/payments/domain/repositories/payments_repository.dart';
import 'package:ehealth/features/payments/domain/usecases/initiate_payment.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final paymentsRemoteDataSourceProvider = Provider<PaymentsRemoteDataSource>((ref) {
  return PaymentsRemoteDataSourceImpl(ref.watch(dioProvider));
});

final paymentsRepositoryProvider = Provider<PaymentsRepository>((ref) {
  return PaymentsRepositoryImpl(ref.watch(paymentsRemoteDataSourceProvider));
});

final initiatePaymentProvider = Provider<InitiatePayment>((ref) {
  return InitiatePayment(ref.watch(paymentsRepositoryProvider));
});
