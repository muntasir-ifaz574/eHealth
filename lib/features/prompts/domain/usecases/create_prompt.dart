import 'package:ehealth/core/result/result.dart';
import 'package:ehealth/core/usecase/usecase.dart';
import 'package:ehealth/features/prompts/domain/entities/prompt_result.dart';
import 'package:ehealth/features/prompts/domain/repositories/prompts_repository.dart';

class CreatePrompt implements UseCase<PromptResult, String> {
  const CreatePrompt(this._repository);

  final PromptsRepository _repository;

  @override
  Future<Result<PromptResult>> call(String text) => _repository.createPrompt(text);
}
