import 'package:ehealth/features/payments/domain/entities/payment_initiation.dart';

class PaymentInitiationModel extends PaymentInitiation {
  const PaymentInitiationModel({
    required super.gatewayUrl,
    super.transactionId,
  });

  factory PaymentInitiationModel.fromJson(Map<String, dynamic> json) {
    final gatewayUrl =
        json['GatewayPageURL'] ??
        json['gatewayUrl'] ??
        json['url'] ??
        json['paymentUrl'];
    return PaymentInitiationModel(
      gatewayUrl: gatewayUrl as String,
      transactionId:
          (json['tran_id'] ?? json['transactionId'] ?? json['transactionID'])
              ?.toString(),
    );
  }
}
