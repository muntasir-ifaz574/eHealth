import 'package:ehealth/core/widgets/async_value_widget.dart';
import 'package:ehealth/features/prompts/domain/entities/health_progress.dart';
import 'package:ehealth/features/prompts/presentation/providers/prompts_providers.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HealthProgressScreen extends ConsumerWidget {
  const HealthProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(healthProgressProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Health Progress')),
      body: AsyncValueWidget(
        value: progressAsync,
        onRetry: () => ref.invalidate(healthProgressProvider),
        data: (progress) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Expanded(
                    child: _SummaryTile(
                      label: 'Interactions',
                      value: progress.summary.totalInteractions.toString(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SummaryTile(label: 'Avg Severity', value: progress.summary.averageSeverity),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SummaryTile(label: 'Trend', value: progress.summary.overallDelta),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Severity Over Time', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              SizedBox(height: 220, child: _SeverityChart(timeline: progress.timeline)),
              const SizedBox(height: 24),
              const Text('Triage Breakdown', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              _FrequencyRow(frequency: progress.frequencyMap),
            ],
          );
        },
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _SeverityChart extends StatelessWidget {
  const _SeverityChart({required this.timeline});

  final List<HealthTimelinePoint> timeline;

  @override
  Widget build(BuildContext context) {
    if (timeline.isEmpty) return const Center(child: Text('No data yet.'));

    return LineChart(
      LineChartData(
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (var i = 0; i < timeline.length; i++)
                FlSpot(i.toDouble(), timeline[i].severityScore.toDouble()),
            ],
            isCurved: true,
            dotData: const FlDotData(show: false),
          ),
        ],
      ),
    );
  }
}

class _FrequencyRow extends StatelessWidget {
  const _FrequencyRow({required this.frequency});

  final TriageCounts frequency;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _FrequencyChip(label: 'High', count: frequency.high, color: Colors.red),
        const SizedBox(width: 8),
        _FrequencyChip(label: 'Medium', count: frequency.medium, color: Colors.orange),
        const SizedBox(width: 8),
        _FrequencyChip(label: 'Low', count: frequency.low, color: Colors.green),
      ],
    );
  }
}

class _FrequencyChip extends StatelessWidget {
  const _FrequencyChip({required this.label, required this.count, required this.color});

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text('$label: $count'),
      backgroundColor: color.withValues(alpha: 0.15),
      labelStyle: TextStyle(color: color),
    );
  }
}
