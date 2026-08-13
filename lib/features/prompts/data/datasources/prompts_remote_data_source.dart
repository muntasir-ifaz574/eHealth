import 'package:dio/dio.dart';
import 'package:ehealth/core/constants/api_endpoints.dart';
import 'package:ehealth/features/prompts/data/models/health_progress_model.dart';
import 'package:ehealth/features/prompts/data/models/prompt_model.dart';
import 'package:ehealth/features/prompts/data/models/prompt_result_model.dart';

abstract interface class PromptsRemoteDataSource {
  Future<({List<PromptModel> items, String? nextCursor})> fetchPrompts({
    String? afterCursor,
    int? limit,
  });

  Future<PromptResultModel> createPrompt(String text);

  Future<HealthProgressModel> fetchHealthProgress({
    String? period,
    DateTime? from,
    DateTime? to,
  });
}

class PromptsRemoteDataSourceImpl implements PromptsRemoteDataSource {
  PromptsRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<({List<PromptModel> items, String? nextCursor})> fetchPrompts({
    String? afterCursor,
    int? limit,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.getPrompts,
      queryParameters: {'afterCursor': ?afterCursor, 'limit': limit ?? 20},
    );
    final data = response.data!;
    final items = (data['data'] as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(PromptModel.fromJson)
        .toList();
    return (items: items, nextCursor: data['nextCursor'] as String?);
  }

  @override
  Future<PromptResultModel> createPrompt(String text) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.createPromptBackup,
      data: {'text': text, 'generatedBy': 'USER'},
    );
    return PromptResultModel.fromJson(response.data!);
  }

  @override
  Future<HealthProgressModel> fetchHealthProgress({
    String? period,
    DateTime? from,
    DateTime? to,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.healthProgress,
      queryParameters: {
        'period': ?period,
        if (from != null) 'from': from.toUtc().toIso8601String(),
        if (to != null) 'to': to.toUtc().toIso8601String(),
      },
    );
    return HealthProgressModel.fromJson(response.data!);
  }
}
