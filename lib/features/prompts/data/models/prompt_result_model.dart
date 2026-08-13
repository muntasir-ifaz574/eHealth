import 'package:ehealth/features/prompts/domain/entities/prompt_result.dart';
import 'package:ehealth/features/prompts/domain/entities/triage_level.dart';

class FirstAidModel extends FirstAid {
  const FirstAidModel({
    required super.code,
    required super.title,
    required super.steps,
  });
  factory FirstAidModel.fromDynamic(dynamic value) {
    if (value is String) {
      return FirstAidModel(code: '', title: '', steps: [value]);
    }

    final json = value as Map<String, dynamic>;
    final description = json['description'] as Map<String, dynamic>?;
    return FirstAidModel(
      code: json['code'] as String? ?? '',
      title: description?['title'] as String? ?? '',
      steps:
          (description?['steps'] as List<dynamic>?)?.cast<String>() ?? const [],
    );
  }
}

class PromptResultModel extends PromptResult {
  const PromptResultModel({
    required super.generatedBy,
    required super.triageLevel,
    required super.firstAid,
    required super.hospitalLookupNeeded,
    super.message,
  });

  factory PromptResultModel.fromJson(Map<String, dynamic> json) {
    final firstAidJson = json['firstAid'];
    return PromptResultModel(
      generatedBy: json['generatedBy'] as String?,
      triageLevel: TriageLevel.fromJson(json['triageLevel'] as String?),
      firstAid: firstAidJson != null
          ? FirstAidModel.fromDynamic(firstAidJson)
          : null,
      hospitalLookupNeeded: json['hospitalLookupNeeded'] as bool?,
      message: json['message'] as String?,
    );
  }
}
