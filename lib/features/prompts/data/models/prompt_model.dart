import 'package:ehealth/features/prompts/domain/entities/prompt.dart';
import 'package:ehealth/features/prompts/domain/entities/triage_level.dart';

class PromptModel extends Prompt {
  const PromptModel({
    required super.id,
    required super.generatedBy,
    super.text,
    super.triageLevel,
    super.firstAidString,
    super.hospitalLookupNeeded,
    super.createdAt,
  });

  factory PromptModel.fromJson(Map<String, dynamic> json) {
    final dateInfo = json['dateInfo'];
    final createdAtRaw = dateInfo is Map ? dateInfo['createdAt'] as String? : null;
    return PromptModel(
      id: json['id'] as String,
      generatedBy: json['generatedBy'] as String,
      text: json['text'] as String?,
      triageLevel: TriageLevel.fromJson(json['triageLevel'] as String?),
      firstAidString: json['firstAidString'] as String?,
      hospitalLookupNeeded: json['hospitalLookupNeeded'] as bool?,
      createdAt: createdAtRaw != null ? DateTime.tryParse(createdAtRaw) : null,
    );
  }
}
