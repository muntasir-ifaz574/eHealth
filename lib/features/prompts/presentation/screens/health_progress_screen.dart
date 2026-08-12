import 'dart:math' as math;

import 'package:ehealth/core/theme/app_colors.dart';
import 'package:ehealth/core/theme/app_spacing.dart';
import 'package:ehealth/core/theme/app_text_styles.dart';
import 'package:ehealth/core/widgets/app_card.dart';
import 'package:ehealth/core/widgets/async_value_widget.dart';
import 'package:ehealth/core/widgets/pill_chip.dart';
import 'package:ehealth/features/prompts/domain/entities/health_progress.dart';
import 'package:ehealth/features/prompts/presentation/providers/prompts_providers.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _monthAbbreviations = [
  'JAN',
  'FEB',
  'MAR',
  'APR',
  'MAY',
  'JUN',
  'JUL',
  'AUG',
  'SEP',
  'OCT',
  'NOV',
  'DEC',
];

class HealthProgressScreen extends ConsumerWidget {
  const HealthProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(healthProgressProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(title: const Text('Health Progress')),
      body: AsyncValueWidget(
        value: progressAsync,
        onRetry: () => ref.invalidate(healthProgressProvider),
        data: (progress) {
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.marginMobile),
            children: [
              _OverallStatusCard(summary: progress.summary),
              const SizedBox(height: AppSpacing.sm),
              AppCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('SEVERITY TIMELINE', style: _labelStyle),
                    const SizedBox(height: AppSpacing.sm),
                    SizedBox(height: 220, child: _SeverityChart(timeline: progress.timeline)),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              _TriageFrequencyCard(frequency: progress.frequencyMap),
            ],
          );
        },
      ),
    );
  }
}

TextStyle get _labelStyle => AppTextStyles.labelCaps.copyWith(color: AppColors.outline);

class _OverallStatusCard extends StatelessWidget {
  const _OverallStatusCard({required this.summary});

  final HealthProgressSummary summary;

  @override
  Widget build(BuildContext context) {
    final trendColor = _trendColor(summary.overallDelta);
    final trendIcon = _trendIcon(summary.overallDelta);

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('OVERALL STATUS', style: _labelStyle),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(_titleCase(summary.overallDelta), style: AppTextStyles.headlineLg),
              const SizedBox(width: AppSpacing.xs),
              Icon(trendIcon, color: trendColor),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Based on ${summary.totalInteractions} interactions.',
            style: AppTextStyles.bodySm,
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(height: 1, color: AppColors.outlineVariant),
          const SizedBox(height: AppSpacing.md),
          Text('AVERAGE SEVERITY', style: _labelStyle),
          const SizedBox(height: AppSpacing.sm),
          _AverageSeverityIndicator(averageSeverity: summary.averageSeverity),
        ],
      ),
    );
  }
}

class _AverageSeverityIndicator extends StatelessWidget {
  const _AverageSeverityIndicator({required this.averageSeverity});

  final String averageSeverity;

  @override
  Widget build(BuildContext context) {
    final numericValue = double.tryParse(averageSeverity);
    if (numericValue == null) {
      return PillChip(label: averageSeverity.toUpperCase(), color: _categoryColor(averageSeverity));
    }

    final color = _severityValueColor(numericValue);
    final progress = (numericValue / 10).clamp(0.0, 1.0);

    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Text(
            numericValue.toStringAsFixed(1),
            style: AppTextStyles.headlineMd.copyWith(color: color),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: AppColors.surfaceVariant,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('LOW', style: _labelStyle.copyWith(fontSize: 10)),
                  Text('HIGH', style: _labelStyle.copyWith(fontSize: 10)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SeverityChart extends StatelessWidget {
  const _SeverityChart({required this.timeline});

  final List<HealthTimelinePoint> timeline;

  @override
  Widget build(BuildContext context) {
    if (timeline.isEmpty) {
      return const Center(child: Text('No data yet.'));
    }

    final highestScore = timeline.map((p) => p.severityScore.toDouble()).reduce(math.max);
    final maxY = highestScore > 10 ? ((highestScore / 5).ceil() * 5).toDouble() : 10.0;
    final lastIndex = timeline.length - 1;
    final midIndex = lastIndex ~/ 2;

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxY,
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 2,
          getDrawingHorizontalLine: (_) =>
              const FlLine(color: AppColors.outlineVariant, strokeWidth: 1, dashArray: [2, 2]),
        ),
        titlesData: FlTitlesData(
          show: true,
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: 5,
              getTitlesWidget: (value, meta) =>
                  Text(value.toInt().toString(), style: _labelStyle.copyWith(fontSize: 10)),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              getTitlesWidget: (value, meta) {
                final index = value.round();
                if (index != 0 && index != midIndex && index != lastIndex) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    _formatAxisDate(timeline[index].date),
                    style: _labelStyle.copyWith(fontSize: 10),
                  ),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (var i = 0; i < timeline.length; i++)
                FlSpot(i.toDouble(), timeline[i].severityScore.toDouble()),
            ],
            isCurved: true,
            color: AppColors.electricBlue,
            barWidth: 2,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                radius: 4,
                color: _dominantTriageColor(timeline[index].triageCounts),
                strokeWidth: 0,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppColors.electricBlue.withValues(alpha: 0.1),
                  AppColors.electricBlue.withValues(alpha: 0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TriageFrequencyCard extends StatelessWidget {
  const _TriageFrequencyCard({required this.frequency});

  final TriageCounts frequency;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('TRIAGE FREQUENCY', style: _labelStyle),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _TriageStatTile(
                  icon: Icons.error,
                  color: AppColors.triageHigh,
                  count: frequency.high,
                  label: 'HIGH SEVERITY',
                ),
              ),
              Expanded(
                child: _TriageStatTile(
                  icon: Icons.warning,
                  color: AppColors.triageMedium,
                  count: frequency.medium,
                  label: 'MEDIUM SEVERITY',
                ),
              ),
              Expanded(
                child: _TriageStatTile(
                  icon: Icons.check_circle,
                  color: AppColors.triageLow,
                  count: frequency.low,
                  label: 'LOW SEVERITY',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TriageStatTile extends StatelessWidget {
  const _TriageStatTile({
    required this.icon,
    required this.color,
    required this.count,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final int count;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Icon(icon, color: color),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(count.toString(), style: AppTextStyles.headlineMd),
        const SizedBox(height: 2),
        Text(label, style: _labelStyle.copyWith(fontSize: 10), textAlign: TextAlign.center),
      ],
    );
  }
}

Color _dominantTriageColor(TriageCounts counts) {
  final maxValue = math.max(counts.high, math.max(counts.medium, counts.low));
  if (maxValue == 0) return AppColors.outline;
  if (counts.high == maxValue) return AppColors.triageHigh;
  if (counts.medium == maxValue) return AppColors.triageMedium;
  return AppColors.triageLow;
}

Color _severityValueColor(double value) {
  if (value >= 6.67) return AppColors.triageHigh;
  if (value >= 3.33) return AppColors.triageMedium;
  return AppColors.triageLow;
}

Color _categoryColor(String category) {
  final upper = category.toUpperCase();
  if (upper.contains('HIGH')) return AppColors.triageHigh;
  if (upper.contains('MED')) return AppColors.triageMedium;
  if (upper.contains('LOW')) return AppColors.triageLow;
  return AppColors.outline;
}

IconData _trendIcon(String overallDelta) {
  final upper = overallDelta.toUpperCase();
  if (upper.contains('IMPROV')) return Icons.trending_down;
  if (upper.contains('WORSEN')) return Icons.trending_up;
  return Icons.trending_flat;
}

Color _trendColor(String overallDelta) {
  final upper = overallDelta.toUpperCase();
  if (upper.contains('IMPROV')) return AppColors.triageLow;
  if (upper.contains('WORSEN')) return AppColors.triageHigh;
  return AppColors.outline;
}

String _titleCase(String value) {
  if (value.isEmpty) return value;
  return '${value[0].toUpperCase()}${value.substring(1).toLowerCase()}';
}

String _formatAxisDate(String date) {
  final parsed = DateTime.tryParse(date);
  if (parsed == null) return date.toUpperCase();
  return '${_monthAbbreviations[parsed.month - 1]} ${parsed.day}';
}
