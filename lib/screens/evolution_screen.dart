import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
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
    final asymmetrySessions = ref.watch(asymmetrySessionHistoryProvider);

    final mode = ref.watch(historyModeProvider);

    final l = AppLocalizations.of(context)!;

    if (athlete == null) {
      return Center(
        child: Text(
          l.selectAthleteToViewEvolution,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
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
              Text(
                l.evolution,
                style: const TextStyle(
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
              child: Text(
                l.errorWithMessage(err.toString()),
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ),
            data: (allTests) {
              final statsAsync = ref.watch(athleteEvolutionStatsProvider);
              return statsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.brand),
                ),
                error: (err, _) => Center(
                  child: Text(
                    l.errorWithMessage(err.toString()),
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ),
                data: (stats) {
                  if (mode == 2) {
                    return _buildAsymmetryTab(
                      l,
                      asymmetrySessions,
                      allTests,
                      stats,
                    );
                  }
                  if (mode == 1) {
                    return _buildRsiTab(l, rsiTests, allTests, stats);
                  }
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        _buildMetricCards(l, stats),
                        const SizedBox(height: 20),
                        _buildChart(baselines, fatigueTests),
                        const SizedBox(height: 24),
                        _buildRecentTests(l, allTests),
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

  Widget _buildAsymmetryTab(
    AppLocalizations l,
    List<AsymmetrySessionPoint> sessions,
    List<JumpTest> allTests,
    AthleteEvolutionStats stats,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          _buildMetricCards(l, stats),
          const SizedBox(height: 20),
          _buildAsymmetryChart(l, sessions),
          const SizedBox(height: 24),
          _buildRecentTests(l, allTests),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildAsymmetryChart(
    AppLocalizations l,
    List<AsymmetrySessionPoint> sessions,
  ) {
    if (sessions.isEmpty) {
      return Container(
        height: 250,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Text(
          l.noAsymmetryData,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
      );
    }

    final spots = <FlSpot>[];
    final xLabels = <int, String>{};
    for (var i = 0; i < sessions.length; i++) {
      spots.add(FlSpot(i.toDouble(), sessions[i].asymmetryPct));
      xLabels[i] = DateFormat('MM/dd').format(sessions[i].timestamp);
    }

    final allY = spots.map((s) => s.y).toList();
    final minY = allY.reduce((a, b) => a < b ? a : b);
    final maxY = allY.reduce((a, b) => a > b ? a : b);
    // Always include 0 and ensure ±15% bands are visible
    final chartMinY = [minY - 5, -20.0].reduce((a, b) => a < b ? a : b);
    final chartMaxY = [maxY + 5, 20.0].reduce((a, b) => a > b ? a : b);
    final yInterval = ((chartMaxY - chartMinY) / 6).clamp(2.0, double.infinity);

    final maxXVal = (sessions.length - 1).toDouble().clamp(
      1.0,
      double.infinity,
    );
    final xInterval = (maxXVal / 4).ceilToDouble().clamp(1.0, double.infinity);

    Color dotColor(double pct) {
      final abs = pct.abs();
      if (abs < 5) return Colors.green;
      if (abs < 10) return Colors.amber;
      if (abs < 15) return Colors.orange;
      return Colors.red;
    }

    return Container(
      height: 280,
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
          minY: chartMinY,
          maxY: chartMaxY,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: yInterval,
            getDrawingHorizontalLine: (value) {
              if (value == 0) {
                return const FlLine(
                  color: AppColors.textSecondary,
                  strokeWidth: 1.2,
                );
              }
              if (value.abs() == 5 || value.abs() == 10 || value.abs() == 15) {
                return FlLine(
                  color: AppColors.borderLight.withAlpha(120),
                  strokeWidth: 0.8,
                  dashArray: [4, 4],
                );
              }
              return FlLine(color: AppColors.borderSubtle, strokeWidth: 0.5);
            },
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
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
                        color: AppColors.textTertiary,
                        fontSize: 10,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 44,
                interval: yInterval,
                getTitlesWidget: (value, _) => Text(
                  '${value >= 0 ? '+' : ''}${value.round()}%',
                  style: const TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 10,
                  ),
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
                final session = idx >= 0 && idx < sessions.length
                    ? sessions[idx]
                    : null;
                final dateStr = session != null
                    ? DateFormat('MMM dd, HH:mm').format(session.timestamp)
                    : '';
                final stronger = session?.strongerLeg == 'right'
                    ? l.rightStronger
                    : l.leftStronger;
                return LineTooltipItem(
                  '${spot.y >= 0 ? '+' : ''}${spot.y.round()}%\n$stronger stronger\n$dateStr',
                  TextStyle(
                    color: dotColor(spot.y),
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
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                  radius: 5,
                  color: dotColor(spot.y),
                  strokeWidth: 1.5,
                  strokeColor: AppColors.surface,
                ),
              ),
              belowBarData: BarAreaData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRsiTab(
    AppLocalizations l,
    List<JumpTest> rsiTests,
    List<JumpTest> allTests,
    AthleteEvolutionStats stats,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          _buildMetricCards(l, stats),
          const SizedBox(height: 20),
          _buildRsiChart(l, rsiTests),
          const SizedBox(height: 24),
          _buildRecentTests(l, allTests),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildRsiChart(AppLocalizations l, List<JumpTest> rsiTests) {
    if (rsiTests.length < 2) {
      return Container(
        height: 250,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Text(
          l.needAtLeast2RsiTests,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
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
    final xInterval = maxXVal > 0
        ? (maxXVal / 4).ceilToDouble().clamp(1.0, double.infinity)
        : 1.0;

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
            getDrawingHorizontalLine: (_) =>
                FlLine(color: AppColors.borderSubtle, strokeWidth: 0.5),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
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
                        color: AppColors.textTertiary,
                        fontSize: 10,
                      ),
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
                    color: AppColors.textTertiary,
                    fontSize: 10,
                  ),
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
                    ? DateFormat(
                        'MMM dd, HH:mm',
                      ).format(rsiTests[idx].timestamp)
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

  Widget _buildMetricCards(AppLocalizations l, AthleteEvolutionStats stats) {
    return Row(
      children: [
        Expanded(
          child: _metricCard(
            label: _evolutionMetricLabel(l, stats.title1),
            value: stats.val1,
            isPositive: stats.isPositive1,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _metricCard(
            label: _evolutionMetricLabel(l, stats.title2),
            value: stats.val2,
            isPositive: stats.isPositive2,
          ),
        ),
      ],
    );
  }

  String _evolutionMetricLabel(AppLocalizations l, EvolutionMetricLabel label) {
    return switch (label) {
      EvolutionMetricLabel.latestAsymmetry => l.evolutionLatestAsymmetry,
      EvolutionMetricLabel.change => l.evolutionChange,
      EvolutionMetricLabel.heightGain => l.evolutionHeightGain,
      EvolutionMetricLabel.versusGroupMean => l.evolutionVsGroupMean,
      EvolutionMetricLabel.rsiGain => l.evolutionRsiGain,
    };
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
      valueColor = isPositive
          ? const Color(0xFF4ADE80)
          : const Color(0xFFF87171);
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
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
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
    final xInterval = maxXVal > 0
        ? (maxXVal / 4).ceilToDouble().clamp(1.0, double.infinity)
        : 1.0;

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
            getDrawingHorizontalLine: (_) =>
                FlLine(color: AppColors.borderSubtle, strokeWidth: 0.5),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
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
                        color: AppColors.textTertiary,
                        fontSize: 10,
                      ),
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
                      color: AppColors.textTertiary,
                      fontSize: 10,
                    ),
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
                    ? DateFormat(
                        'MMM dd, HH:mm',
                      ).format(chartPoints[idx].timestamp)
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
    List<JumpTest> baselines,
    List<JumpTest> fatigueTests,
  ) {
    final points = <_ChartPoint>[];

    // Baseline: group by session, take max height per session
    final Map<int, JumpTest> bestPerSession = {};
    for (final t in baselines) {
      final key = t.sessionId ?? t.id;
      if (!bestPerSession.containsKey(key) ||
          t.heightCm > bestPerSession[key]!.heightCm) {
        bestPerSession[key] = t;
      }
    }
    for (final t in bestPerSession.values) {
      points.add(
        _ChartPoint(
          timestamp: t.timestamp,
          heightCm: t.heightCm,
          isBaseline: true,
        ),
      );
    }

    // Fatigue tests: one point per test
    for (final t in fatigueTests) {
      points.add(
        _ChartPoint(
          timestamp: t.timestamp,
          heightCm: t.heightCm,
          isBaseline: false,
        ),
      );
    }

    points.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return points;
  }

  Widget _buildRecentTests(AppLocalizations l, List<JumpTest> allTests) {
    final processed = _processRecentTests(allTests);
    if (processed.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.recentTests,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        ...processed.take(5).map((t) => _buildTestRow(l, t)),
      ],
    );
  }

  List<_ProcessedTest> _processRecentTests(List<JumpTest> allTests) {
    final processed = <_ProcessedTest>[];
    final seenAsymmetrySessions = <int>{};

    for (final test in allTests) {
      if (test.testType == 'asymmetry') {
        final sid = test.sessionId ?? test.id;
        if (seenAsymmetrySessions.contains(sid)) continue;
        seenAsymmetrySessions.add(sid);

        final pair = allTests
            .where(
              (t) => t.testType == 'asymmetry' && (t.sessionId ?? t.id) == sid,
            )
            .toList();
        final leftList = pair.where((t) => t.leg == 'left').toList();
        final rightList = pair.where((t) => t.leg == 'right').toList();

        if (leftList.isNotEmpty && rightList.isNotEmpty) {
          final leftH = leftList.first.heightCm;
          final rightH = rightList.first.heightCm;
          final maxH = leftH > rightH ? leftH : rightH;
          final pct = maxH > 0 ? (rightH - leftH) / maxH * 100 : 0.0;

          processed.add(
            _ProcessedTest(
              testType: 'asymmetry',
              timestamp:
                  leftList.first.timestamp.isBefore(rightList.first.timestamp)
                  ? leftList.first.timestamp
                  : rightList.first.timestamp,
              asymmetryPct: pct,
              heightCm: maxH,
            ),
          );
        }
      } else {
        processed.add(
          _ProcessedTest(
            testType: test.testType,
            timestamp: test.timestamp,
            heightCm: test.heightCm,
            rsiScore: test.rsiScore,
          ),
        );
      }
    }

    processed.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return processed;
  }

  Widget _buildTestRow(AppLocalizations l, _ProcessedTest test) {
    final dateStr = DateFormat(
      'MMM dd, yyyy \u2022 HH:mm',
    ).format(test.timestamp);
    final typeLabel = switch (test.testType) {
      'cmj_baseline' => l.typeCmj,
      'fatigue' => l.typeFatigue,
      'rsi' => l.typeRsi,
      'asymmetry' => l.asymmetricTest,
      _ => test.testType,
    };
    final typeColor = switch (test.testType) {
      'cmj_baseline' => AppColors.brand,
      'fatigue' => const Color(0xFFFBBF24),
      'rsi' => const Color(0xFFA78BFA),
      'asymmetry' => const Color(0xFF8B5CF6),
      _ => AppColors.textSecondary,
    };

    final displayValue = test.testType == 'asymmetry'
        ? '${test.asymmetryPct! >= 0 ? '+' : ''}${test.asymmetryPct!.round()}%'
        : test.testType == 'rsi' && test.rsiScore != null
        ? test.rsiScore!.toStringAsFixed(2)
        : '${test.heightCm!.toStringAsFixed(1)} cm';

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
                color: typeColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              dateStr,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
          Text(
            displayValue,
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

class _ProcessedTest {
  final String testType;
  final DateTime timestamp;
  final double? heightCm;
  final double? rsiScore;
  final double? asymmetryPct;

  const _ProcessedTest({
    required this.testType,
    required this.timestamp,
    this.heightCm,
    this.rsiScore,
    this.asymmetryPct,
  });
}
