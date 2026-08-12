import 'package:ehealth/core/result/result.dart';
import 'package:ehealth/features/payments/domain/entities/payment_initiation.dart';

abstract interface class PaymentsRepository {
  Future<Result<PaymentInitiation>> initiatePayment({
    required num amount,
    required int userId,
    required int consultationId,
  });

  Future<Result<void>> notifyPaymentSuccess(Map<String, dynamic> data);
}
