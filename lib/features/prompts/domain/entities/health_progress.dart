import 'package:equatable/equatable.dart';

class HealthProgressSummary extends Equatable {
  const HealthProgressSummary({
    required this.totalInteractions,
    required this.averageSeverity,
    required this.overallDelta,
    this.periodStart,
    this.periodEnd,
  });

  final int totalInteractions;
  final String averageSeverity;
  final String overallDelta;
  final String? periodStart;
  final String? periodEnd;

  @override
  List<Object?> get props =>
      [totalInteractions, averageSeverity, overallDelta, periodStart, periodEnd];
}

class TriageCounts extends Equatable {
  const TriageCounts({required this.high, required this.medium, required this.low});

  final int high;
  final int medium;
  final int low;

  @override
  List<Object?> get props => [high, medium, low];
}

class HealthTimelinePoint extends Equatable {
  const HealthTimelinePoint({
    required this.date,
    required this.severityScore,
    required this.triageCounts,
    required this.totalPrompts,
    required this.hospitalLookupCount,
  });

  final String date;
  final num severityScore;
  final TriageCounts triageCounts;
  final int totalPrompts;
  final int hospitalLookupCount;

  @override
  List<Object?> get props =>
      [date, severityScore, triageCounts, totalPrompts, hospitalLookupCount];
}

class HealthProgress extends Equatable {
  const HealthProgress({required this.summary, required this.timeline, required this.frequencyMap});

  final HealthProgressSummary summary;
  final List<HealthTimelinePoint> timeline;
  final TriageCounts frequencyMap;

  @override
  List<Object?> get props => [summary, timeline, frequencyMap];
}
