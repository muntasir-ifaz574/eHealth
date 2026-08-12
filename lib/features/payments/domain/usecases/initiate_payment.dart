import 'package:ehealth/core/result/result.dart';
import 'package:ehealth/core/usecase/usecase.dart';
import 'package:ehealth/features/payments/domain/entities/payment_initiation.dart';
import 'package:ehealth/features/payments/domain/repositories/payments_repository.dart';
import 'package:equatable/equatable.dart';

class InitiatePaymentParams extends Equatable {
  const InitiatePaymentParams({required this.amount, required this.userId, required this.consultationId});

  final num amount;
  final int userId;
  final int consultationId;

  @override
  List<Object?> get props => [amount, userId, consultationId];
}

class InitiatePayment implements UseCase<PaymentInitiation, InitiatePaymentParams> {
  const InitiatePayment(this._repository);

  final PaymentsRepository _repository;

  @override
  Future<Result<PaymentInitiation>> call(InitiatePaymentParams params) {
    return _repository.initiatePayment(
      amount: params.amount,
      userId: params.userId,
      consultationId: params.consultationId,
    );
  }
}
