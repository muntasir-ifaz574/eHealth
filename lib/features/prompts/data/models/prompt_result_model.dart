import 'package:ehealth/features/prompts/domain/entities/prompt_result.dart';
import 'package:ehealth/features/prompts/domain/entities/triage_level.dart';

class FirstAidModel extends FirstAid {
  const FirstAidModel({required super.code, required super.title, required super.steps});

  factory FirstAidModel.fromJson(Map<String, dynamic> json) {
    final description = json['description'] as Map<String, dynamic>;
    return FirstAidModel(
      code: json['code'] as String,
      title: description['title'] as String,
      steps: (description['steps'] as List<dynamic>).cast<String>(),
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
    return PromptResultModel(
      generatedBy: json['generatedBy'] as String,
      triageLevel: TriageLevel.fromJson(json['triageLevel'] as String?) ?? TriageLevel.low,
      firstAid: FirstAidModel.fromJson(json['firstAid'] as Map<String, dynamic>),
      hospitalLookupNeeded: json['hospitalLookupNeeded'] as bool? ?? false,
      message: json['message'] as String?,
    );
  }
}
