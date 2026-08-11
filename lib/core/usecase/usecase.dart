import 'package:ehealth/core/result/result.dart';
import 'package:equatable/equatable.dart';

/// Base contract every domain use case implements.
///
/// [ReturnType] is the success value, [Params] the input. Use [NoParams]
/// when a use case takes no arguments.
abstract interface class UseCase<ReturnType, Params> {
  Future<Result<ReturnType>> call(Params params);
}

/// Synchronous variant for use cases that never need to await anything
/// (e.g. pure parsing/interpretation logic).
abstract interface class SyncUseCase<ReturnType, Params> {
  ReturnType call(Params params);
}

class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}
