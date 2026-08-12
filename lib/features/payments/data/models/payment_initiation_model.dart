import 'package:ehealth/features/payments/domain/entities/payment_initiation.dart';

class PaymentInitiationModel extends PaymentInitiation {
  const PaymentInitiationModel({required super.gatewayUrl, super.transactionId});

  factory PaymentInitiationModel.fromJson(Map<String, dynamic> json) {
    // Confirmed from a live response: SSLCOMMERZ's own field names
    // (GatewayPageURL, tran_id) pass straight through the backend — the
    // gatewayUrl/transactionId guesses were wrong.
    final gatewayUrl = json['GatewayPageURL'] ??
        json['gatewayUrl'] ??
        json['url'] ??
        json['paymentUrl'];
    return PaymentInitiationModel(
      gatewayUrl: gatewayUrl as String,
      transactionId: (json['tran_id'] ?? json['transactionId'] ?? json['transactionID'])?.toString(),
    );
  }
}
