import 'package:ehealth/core/result/result.dart';
import 'package:equatable/equatable.dart';

abstract interface class UseCase<ReturnType, Params> {
  Future<Result<ReturnType>> call(Params params);
}

abstract interface class SyncUseCase<ReturnType, Params> {
  ReturnType call(Params params);
}

class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}
