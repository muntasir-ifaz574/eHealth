import 'package:ehealth/core/result/result.dart';
import 'package:ehealth/features/prompts/domain/entities/health_progress.dart';
import 'package:ehealth/features/prompts/domain/entities/prompt.dart';
import 'package:ehealth/features/prompts/domain/entities/prompt_result.dart';

abstract interface class PromptsRepository {
  Future<Result<PromptPage>> getPrompts({String? afterCursor, int? limit});

  Future<Result<PromptResult>> createPrompt(String text);

  Future<Result<HealthProgress>> getHealthProgress({String? period, DateTime? from, DateTime? to});
}
