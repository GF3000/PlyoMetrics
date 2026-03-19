import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../core/theme.dart';
import '../models/jump_test.dart';
import '../providers/management_providers.dart';
import '../widgets/neon_mode_toggle.dart';

class EvolutionScreen extends ConsumerWidget {
  const EvolutionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final athlete = ref.watch(activeAthleteProvider);
    final historyAsync = ref.watch(athleteJumpHistoryProvider);
    final baselines = ref.watch(baselineHistoryProvider);
    final fatigueTests = ref.watch(fatigueHistoryProvider);
    final rsiTests = ref.watch(rsiHistoryProvider);

    final mode = ref.watch(historyModeProvider);

    if (athlete == null) {
      return const Center(
        child: Text(
          'Select an athlete to view evolution',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Evolution',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                athlete.name,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        // Tab selector
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: const NeonModeToggle(),
        ),
        // Content
        Expanded(
          child: historyAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.brand),
            ),
            error: (err, _) => Center(
              child: Text('Error: $err',
                  style: const TextStyle(color: AppColors.textSecondary)),
            ),
            data: (allTests) {
              final statsAsync = ref.watch(athleteEvolutionStatsProvider);
              return statsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.brand),
                ),
                error: (err, _) => Center(
                  child: Text('Error: $err',
                      style: const TextStyle(color: AppColors.textSecondary)),
                ),
                data: (stats) {
                   if (mode == 1) {
                     return _buildRsiTab(rsiTests, allTests, stats);
                   }
                   return SingleChildScrollView(
                     padding: const EdgeInsets.symmetric(horizontal: 16),
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         const SizedBox(height: 12),
                         _buildMetricCards(stats),
                         const SizedBox(height: 20),
                         _buildChart(baselines, fatigueTests),
                         const SizedBox(height: 24),
                         _buildRecentTests(allTests),
                         const SizedBox(height: 16),
                       ],
                     ),
                   );
                 },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRsiTab(List<JumpTest> rsiTests, List<JumpTest> allTests, ({String title1, String val1, String title2, String val2, bool isPositive1, bool isPositive2}) stats) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          _buildMetricCards(stats),
          const SizedBox(height: 20),
          _buildRsiChart(rsiTests),
          const SizedBox(height: 24),
          _buildRecentTests(allTests),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildRsiChart(List<JumpTest> rsiTests) {
    if (rsiTests.length < 2) {
      return Container(
        height: 250,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: const Text(
          'Need at least 2 RSI tests to chart',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
      );
    }

    final spots = <FlSpot>[];
    final xLabels = <int, String>{};
    for (var i = 0; i < rsiTests.length; i++) {
      final t = rsiTests[i];
      spots.add(FlSpot(i.toDouble(), t.rsiScore ?? 0));
      xLabels[i] = DateFormat('MM/dd').format(t.timestamp);
    }

    final allY = spots.map((s) => s.y).toList();
    final minY = allY.reduce((a, b) => a < b ? a : b);
    final maxY = allY.reduce((a, b) => a > b ? a : b);
    final yPadding = ((maxY - minY) * 0.15).clamp(0.2, 2.0);
    final yRange = (maxY + yPadding) - (minY - yPadding);
    final yInterval = (yRange / 5).clamp(0.1, double.infinity);

    final maxXVal = (rsiTests.length - 1).toDouble();
    final xInterval =
        maxXVal > 0 ? (maxXVal / 4).ceilToDouble().clamp(1.0, double.infinity) : 1.0;

    return Container(
      height: 250,
      padding: const EdgeInsets.fromLTRB(0, 16, 8, 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: maxXVal,
          minY: minY - yPadding,
          maxY: maxY + yPadding,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: yInterval,
            getDrawingHorizontalLine: (_) => FlLine(
              color: AppColors.borderSubtle,
              strokeWidth: 0.5,
            ),
          ),
          titlesData: FlTitlesData(
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                interval: xInterval,
                getTitlesWidget: (value, _) {
                  final label = xLabels[value.toInt()];
                  if (label == null) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      label,
                      style: const TextStyle(
                          color: AppColors.textTertiary, fontSize: 10),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: yInterval,
                getTitlesWidget: (value, _) => Text(
                  value.toStringAsFixed(1),
                  style: const TextStyle(
                      color: AppColors.textTertiary, fontSize: 10),
                ),
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => AppColors.card,
              getTooltipItems: (touchedSpots) => touchedSpots.map((spot) {
                final idx = spot.x.toInt();
                final label = idx >= 0 && idx < rsiTests.length
                    ? DateFormat('MMM dd, HH:mm')
                        .format(rsiTests[idx].timestamp)
                    : '';
                return LineTooltipItem(
                  '${spot.y.toStringAsFixed(2)} RSI\n$label',
                  TextStyle(
                    color: spot.bar.color ?? AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                );
              }).toList(),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              preventCurveOverShooting: true,
              color: const Color(0xFFA78BFA),
              barWidth: 2.5,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: const Color(0xFFA78BFA).withAlpha(30),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildMetricCards(
      ({String title1, String val1, String title2, String val2, bool isPositive1, bool isPositive2}) stats) {
    return Row(
      children: [
        Expanded(
          child: _metricCard(
            label: stats.title1,
            value: stats.val1,
            isPositive: stats.isPositive1,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _metricCard(
            label: stats.title2,
            value: stats.val2,
            isPositive: stats.isPositive2,
          ),
        ),
      ],
    );
  }

  Widget _metricCard({
    required String label,
    required String value,
    required bool isPositive,
  }) {
    final Color valueColor;
    if (value == '-') {
      valueColor = AppColors.textSecondary;
    } else {
      valueColor = isPositive ? const Color(0xFF4ADE80) : const Color(0xFFF87171);
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(List<JumpTest> baselines, List<JumpTest> fatigueTests) {
    // 1. Build unified chart points sorted chronologically
    final chartPoints = _buildChartPoints(baselines, fatigueTests);
    if (chartPoints.isEmpty) return const SizedBox.shrink();

    // 2. Assign index-based X values and pre-compute date labels
    final xLabels = <int, String>{};
    final dateCounts = <String, int>{};
    final dateFirstIndex = <String, int>{};
    for (var i = 0; i < chartPoints.length; i++) {
      final dateKey = DateFormat('MM/dd').format(chartPoints[i].timestamp);
      dateCounts[dateKey] = (dateCounts[dateKey] ?? 0) + 1;
      dateFirstIndex.putIfAbsent(dateKey, () => i);
    }
    for (var i = 0; i < chartPoints.length; i++) {
      final dateKey = DateFormat('MM/dd').format(chartPoints[i].timestamp);
      if (dateCounts[dateKey]! > 1) {
        final occurrence = i - dateFirstIndex[dateKey]! + 1;
        xLabels[i] = '$dateKey ($occurrence)';
      } else {
        xLabels[i] = dateKey;
      }
    }

    // 3. Build FlSpot lists by type
    final baselineSpots = <FlSpot>[];
    final fatigueSpots = <FlSpot>[];

    for (var i = 0; i < chartPoints.length; i++) {
      final p = chartPoints[i];
      final spot = FlSpot(i.toDouble(), p.heightCm);
      if (p.isBaseline) {
        baselineSpots.add(spot);
      } else {
        fatigueSpots.add(spot);
      }
    }

    // Extend baseline step-line to the last chart point
    if (baselineSpots.isNotEmpty) {
      final lastBaseline = baselineSpots.last;
      final endX = (chartPoints.length - 1).toDouble();
      if (endX > lastBaseline.x) {
        baselineSpots.add(FlSpot(endX, lastBaseline.y));
      }
    }

    // 4. Compute Y-axis bounds with integer interval
    final allY = chartPoints.map((p) => p.heightCm).toList();
    final minY = allY.reduce((a, b) => a < b ? a : b);
    final maxY = allY.reduce((a, b) => a > b ? a : b);
    final yPadding = ((maxY - minY) * 0.15).clamp(1.0, 10.0);
    final yRange = (maxY + yPadding) - (minY - yPadding);
    final yInterval = (yRange / 5).ceilToDouble().clamp(1.0, double.infinity);

    // 5. X-axis: show ~4-5 evenly spaced labels
    final maxXVal = (chartPoints.length - 1).toDouble();
    final xInterval =
        maxXVal > 0 ? (maxXVal / 4).ceilToDouble().clamp(1.0, double.infinity) : 1.0;

    return Container(
      height: 250,
      padding: const EdgeInsets.fromLTRB(0, 16, 8, 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: maxXVal,
          minY: minY - yPadding,
          maxY: maxY + yPadding,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: yInterval,
            getDrawingHorizontalLine: (_) => FlLine(
              color: AppColors.borderSubtle,
              strokeWidth: 0.5,
            ),
          ),
          titlesData: FlTitlesData(
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                interval: xInterval,
                getTitlesWidget: (value, _) {
                  final idx = value.toInt();
                  final label = xLabels[idx];
                  if (label == null) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      label,
                      style: const TextStyle(
                          color: AppColors.textTertiary, fontSize: 10),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: yInterval,
                getTitlesWidget: (value, _) {
                  if (value != value.roundToDouble()) {
                    return const SizedBox.shrink();
                  }
                  return Text(
                    value.toStringAsFixed(0),
                    style: const TextStyle(
                        color: AppColors.textTertiary, fontSize: 10),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => AppColors.card,
              getTooltipItems: (spots) => spots.map((spot) {
                final idx = spot.x.toInt();
                final label = idx >= 0 && idx < chartPoints.length
                    ? DateFormat('MMM dd, HH:mm')
                        .format(chartPoints[idx].timestamp)
                    : '';
                return LineTooltipItem(
                  '${spot.y.toStringAsFixed(1)} cm\n$label',
                  TextStyle(
                    color: spot.bar.color ?? AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                );
              }).toList(),
            ),
          ),
          lineBarsData: [
            // Step line for all baseline tests, extended to present
            if (baselineSpots.isNotEmpty)
              LineChartBarData(
                spots: baselineSpots,
                isCurved: false,
                color: AppColors.brand,
                barWidth: 2.5,
                dotData: const FlDotData(show: true),
                belowBarData: BarAreaData(
                  show: true,
                  color: AppColors.brand.withAlpha(30),
                ),
              ),
            if (fatigueSpots.isNotEmpty)
              LineChartBarData(
                spots: fatigueSpots,
                isCurved: true,
                preventCurveOverShooting: true,
                color: AppColors.textSecondary,
                barWidth: 1.5,
                dashArray: [6, 4],
                dotData: const FlDotData(show: true),
              ),
          ],
        ),
      ),
    );
  }

  /// Build a sorted list of chart points from baseline sessions and fatigue tests.
  List<_ChartPoint> _buildChartPoints(
      List<JumpTest> baselines, List<JumpTest> fatigueTests) {
    final points = <_ChartPoint>[];

    // Baseline: group by session, take max height per session
    final Map<int, JumpTest> bestPerSession = {};
    for (final t in baselines) {
      final key = t.baselineSessionId ?? t.id;
      if (!bestPerSession.containsKey(key) ||
          t.heightCm > bestPerSession[key]!.heightCm) {
        bestPerSession[key] = t;
      }
    }
    for (final t in bestPerSession.values) {
      points.add(_ChartPoint(
        timestamp: t.timestamp,
        heightCm: t.heightCm,
        isBaseline: true,
      ));
    }

    // Fatigue tests: one point per test
    for (final t in fatigueTests) {
      points.add(_ChartPoint(
        timestamp: t.timestamp,
        heightCm: t.heightCm,
        isBaseline: false,
      ));
    }

    points.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return points;
  }

  Widget _buildRecentTests(List<JumpTest> allTests) {
    final recent = allTests.take(5).toList();
    if (recent.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Tests',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        ...recent.map(_buildTestRow),
      ],
    );
  }

  Widget _buildTestRow(JumpTest test) {
    final dateStr =
        DateFormat('MMM dd, yyyy \u2022 HH:mm').format(test.timestamp);
    final typeLabel = switch (test.testType) {
      'cmj_baseline' => 'CMJ',
      'fatigue' => 'Fatigue',
      'rsi' => 'RSI',
      _ => test.testType,
    };
    final typeColor = switch (test.testType) {
      'cmj_baseline' => AppColors.brand,
      'fatigue' => const Color(0xFFFBBF24),
      'rsi' => const Color(0xFFA78BFA),
      _ => AppColors.textSecondary,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: typeColor.withAlpha(25),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              typeLabel,
              style: TextStyle(
                  color: typeColor, fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              dateStr,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12),
            ),
          ),
          Text(
            test.testType == 'rsi' && test.rsiScore != null
                ? test.rsiScore!.toStringAsFixed(2)
                : '${test.heightCm.toStringAsFixed(1)} cm',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartPoint {
  final DateTime timestamp;
  final double heightCm;
  final bool isBaseline;

  const _ChartPoint({
    required this.timestamp,
    required this.heightCm,
    required this.isBaseline,
  });
}
