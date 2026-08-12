import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:ehealth/core/error/failures.dart';
import 'package:ehealth/core/network/api_error_mapper.dart';
import 'package:ehealth/core/result/result.dart';
import 'package:ehealth/features/payments/data/datasources/payments_remote_data_source.dart';
import 'package:ehealth/features/payments/domain/entities/payment_initiation.dart';
import 'package:ehealth/features/payments/domain/repositories/payments_repository.dart';

class PaymentsRepositoryImpl implements PaymentsRepository {
  const PaymentsRepositoryImpl(this._remoteDataSource);

  final PaymentsRemoteDataSource _remoteDataSource;

  @override
  Future<Result<PaymentInitiation>> initiatePayment({
    required num amount,
    required int userId,
    required int consultationId,
  }) async {
    try {
      final initiation = await _remoteDataSource.initiatePayment(
        amount: amount,
        userId: userId,
        consultationId: consultationId,
      );
      return Right(initiation);
    } on DioException catch (e) {
      return Left(mapDioException(e));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }
}
