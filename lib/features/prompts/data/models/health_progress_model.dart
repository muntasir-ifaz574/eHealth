import 'package:ehealth/features/prompts/domain/entities/health_progress.dart';

class TriageCountsModel extends TriageCounts {
  const TriageCountsModel({required super.high, required super.medium, required super.low});

  factory TriageCountsModel.fromJson(Map<String, dynamic> json) {
    return TriageCountsModel(
      high: json['HIGH'] as int? ?? 0,
      medium: json['MEDIUM'] as int? ?? 0,
      low: json['LOW'] as int? ?? 0,
    );
  }
}

class HealthProgressSummaryModel extends HealthProgressSummary {
  const HealthProgressSummaryModel({
    required super.totalInteractions,
    required super.averageSeverity,
    required super.overallDelta,
    super.periodStart,
    super.periodEnd,
  });

  factory HealthProgressSummaryModel.fromJson(Map<String, dynamic> json) {
    return HealthProgressSummaryModel(
      totalInteractions: json['totalInteractions'] as int,
      averageSeverity: json['averageSeverity'] as String,
      overallDelta: json['overallDelta'] as String,
      periodStart: json['periodStart'] as String?,
      periodEnd: json['periodEnd'] as String?,
    );
  }
}

class HealthTimelinePointModel extends HealthTimelinePoint {
  const HealthTimelinePointModel({
    required super.date,
    required super.severityScore,
    required super.triageCounts,
    required super.totalPrompts,
    required super.hospitalLookupCount,
  });

  factory HealthTimelinePointModel.fromJson(Map<String, dynamic> json) {
    return HealthTimelinePointModel(
      date: json['date'] as String,
      severityScore: json['severityScore'] as num,
      triageCounts: TriageCountsModel.fromJson(json['triageCounts'] as Map<String, dynamic>),
      totalPrompts: json['totalPrompts'] as int,
      hospitalLookupCount: json['hospitalLookupCount'] as int,
    );
  }
}

class HealthProgressModel extends HealthProgress {
  const HealthProgressModel({
    required super.summary,
    required super.timeline,
    required super.frequencyMap,
  });

  factory HealthProgressModel.fromJson(Map<String, dynamic> json) {
    return HealthProgressModel(
      summary: HealthProgressSummaryModel.fromJson(json['summary'] as Map<String, dynamic>),
      timeline: (json['timeline'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(HealthTimelinePointModel.fromJson)
          .toList(),
      frequencyMap: TriageCountsModel.fromJson(json['frequencyMap'] as Map<String, dynamic>),
    );
  }
}
