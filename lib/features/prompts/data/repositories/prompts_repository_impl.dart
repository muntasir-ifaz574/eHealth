import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:ehealth/core/error/failures.dart';
import 'package:ehealth/core/network/api_error_mapper.dart';
import 'package:ehealth/core/result/result.dart';
import 'package:ehealth/features/prompts/data/datasources/prompts_remote_data_source.dart';
import 'package:ehealth/features/prompts/domain/entities/health_progress.dart';
import 'package:ehealth/features/prompts/domain/entities/prompt.dart';
import 'package:ehealth/features/prompts/domain/entities/prompt_result.dart';
import 'package:ehealth/features/prompts/domain/repositories/prompts_repository.dart';

class PromptsRepositoryImpl implements PromptsRepository {
  const PromptsRepositoryImpl(this._remoteDataSource);

  final PromptsRemoteDataSource _remoteDataSource;

  @override
  Future<Result<PromptPage>> getPrompts({String? afterCursor, int? limit}) async {
    try {
      final page = await _remoteDataSource.fetchPrompts(afterCursor: afterCursor, limit: limit);
      return Right(PromptPage(items: page.items, nextCursor: page.nextCursor));
    } on DioException catch (e) {
      return Left(mapDioException(e));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Result<PromptResult>> createPrompt(String text) async {
    try {
      return Right(await _remoteDataSource.createPrompt(text));
    } on DioException catch (e) {
      return Left(mapDioException(e));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Result<HealthProgress>> getHealthProgress({
    String? period,
    DateTime? from,
    DateTime? to,
  }) async {
    try {
      return Right(await _remoteDataSource.fetchHealthProgress(period: period, from: from, to: to));
    } on DioException catch (e) {
      return Left(mapDioException(e));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }
}
