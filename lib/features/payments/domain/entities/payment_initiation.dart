import 'package:equatable/equatable.dart';

class PaymentInitiation extends Equatable {
  const PaymentInitiation({required this.gatewayUrl, this.transactionId});

  final String gatewayUrl;
  final String? transactionId;

  @override
  List<Object?> get props => [gatewayUrl, transactionId];
}
