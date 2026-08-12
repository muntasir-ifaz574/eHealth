import 'package:ehealth/core/result/result.dart';
import 'package:ehealth/core/usecase/usecase.dart';
import 'package:ehealth/features/prompts/domain/entities/health_progress.dart';
import 'package:ehealth/features/prompts/domain/repositories/prompts_repository.dart';
import 'package:equatable/equatable.dart';

class GetHealthProgressParams extends Equatable {
  const GetHealthProgressParams({this.period, this.from, this.to});

  final String? period;
  final DateTime? from;
  final DateTime? to;

  @override
  List<Object?> get props => [period, from, to];
}

class GetHealthProgress implements UseCase<HealthProgress, GetHealthProgressParams> {
  const GetHealthProgress(this._repository);

  final PromptsRepository _repository;

  @override
  Future<Result<HealthProgress>> call(GetHealthProgressParams params) {
    return _repository.getHealthProgress(period: params.period, from: params.from, to: params.to);
  }
}
