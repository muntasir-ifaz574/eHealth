import 'package:dio/dio.dart';
import 'package:ehealth/core/constants/api_endpoints.dart';
import 'package:ehealth/features/payments/data/models/payment_initiation_model.dart';

abstract interface class PaymentsRemoteDataSource {
  Future<PaymentInitiationModel> initiatePayment({
    required num amount,
    required int userId,
    required int consultationId,
  });
}

class PaymentsRemoteDataSourceImpl implements PaymentsRemoteDataSource {
  PaymentsRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<PaymentInitiationModel> initiatePayment({
    required num amount,
    required int userId,
    required int consultationId,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.initiatePayment,
      data: {'amount': amount, 'userId': userId, 'consultationId': consultationId},
    );
    return PaymentInitiationModel.fromJson(response.data!);
  }
}
