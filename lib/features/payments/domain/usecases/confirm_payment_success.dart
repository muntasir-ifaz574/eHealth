import 'package:ehealth/core/result/result.dart';
import 'package:ehealth/core/usecase/usecase.dart';
import 'package:ehealth/features/payments/domain/repositories/payments_repository.dart';

class ConfirmPaymentSuccess implements UseCase<void, Map<String, dynamic>> {
  const ConfirmPaymentSuccess(this._repository);

  final PaymentsRepository _repository;

  @override
  Future<Result<void>> call(Map<String, dynamic> params) {
    return _repository.notifyPaymentSuccess(params);
  }
}
