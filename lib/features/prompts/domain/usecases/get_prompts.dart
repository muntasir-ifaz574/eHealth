import 'package:ehealth/core/result/result.dart';
import 'package:ehealth/core/usecase/usecase.dart';
import 'package:ehealth/features/prompts/domain/entities/prompt.dart';
import 'package:ehealth/features/prompts/domain/repositories/prompts_repository.dart';
import 'package:equatable/equatable.dart';

class GetPromptsParams extends Equatable {
  const GetPromptsParams({this.afterCursor, this.limit});

  final String? afterCursor;
  final int? limit;

  @override
  List<Object?> get props => [afterCursor, limit];
}

class GetPrompts implements UseCase<PromptPage, GetPromptsParams> {
  const GetPrompts(this._repository);

  final PromptsRepository _repository;

  @override
  Future<Result<PromptPage>> call(GetPromptsParams params) {
    return _repository.getPrompts(afterCursor: params.afterCursor, limit: params.limit);
  }
}
