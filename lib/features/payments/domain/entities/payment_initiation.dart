import 'package:equatable/equatable.dart';

/// The doc doesn't specify this response's field names ("e.g. gateway URL,
/// transaction ID") — `gatewayUrl`/`transactionId` are the best-guess keys;
/// revisit once the real response is seen.
class PaymentInitiation extends Equatable {
  const PaymentInitiation({required this.gatewayUrl, this.transactionId});

  final String gatewayUrl;
  final String? transactionId;

  @override
  List<Object?> get props => [gatewayUrl, transactionId];
}
