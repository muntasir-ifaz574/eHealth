import 'package:ehealth/core/di/core_providers.dart';
import 'package:ehealth/features/prompts/data/datasources/prompts_remote_data_source.dart';
import 'package:ehealth/features/prompts/data/repositories/prompts_repository_impl.dart';
import 'package:ehealth/features/prompts/domain/entities/health_progress.dart';
import 'package:ehealth/features/prompts/domain/entities/prompt.dart';
import 'package:ehealth/features/prompts/domain/repositories/prompts_repository.dart';
import 'package:ehealth/features/prompts/domain/usecases/create_prompt.dart';
import 'package:ehealth/features/prompts/domain/usecases/get_health_progress.dart';
import 'package:ehealth/features/prompts/domain/usecases/get_prompts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final promptsRemoteDataSourceProvider = Provider<PromptsRemoteDataSource>((ref) {
  return PromptsRemoteDataSourceImpl(ref.watch(dioProvider));
});

final promptsRepositoryProvider = Provider<PromptsRepository>((ref) {
  return PromptsRepositoryImpl(ref.watch(promptsRemoteDataSourceProvider));
});

final getPromptsProvider = Provider<GetPrompts>((ref) {
  return GetPrompts(ref.watch(promptsRepositoryProvider));
});

final createPromptProvider = Provider<CreatePrompt>((ref) {
  return CreatePrompt(ref.watch(promptsRepositoryProvider));
});

final getHealthProgressProvider = Provider<GetHealthProgress>((ref) {
  return GetHealthProgress(ref.watch(promptsRepositoryProvider));
});

final recentPromptsProvider = FutureProvider.autoDispose<PromptPage>((ref) async {
  final result = await ref.watch(getPromptsProvider).call(const GetPromptsParams());
  return result.fold((failure) => throw failure, (page) => page);
});

final healthProgressProvider = FutureProvider.autoDispose<HealthProgress>((ref) async {
  final result = await ref.watch(getHealthProgressProvider).call(const GetHealthProgressParams());
  return result.fold((failure) => throw failure, (progress) => progress);
});
