import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme.dart';
import '../l10n/app_localizations.dart';
import '../providers/management_providers.dart';

class GroupOverviewScreen extends ConsumerWidget {
  const GroupOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final group = ref.watch(activeGroupProvider);
    final statsAsync = ref.watch(groupOverviewProvider);
    final chartMode = ref.watch(groupChartModeProvider);

    if (group == null) {
      return Center(
        child: Text(
          l.noAthletesInGroup,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
      );
    }

    return statsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.brand),
      ),
      error: (err, _) => Center(
        child: Text(
          l.noDataAvailable,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
      ),
      data: (stats) {
        if (stats.isEmpty) {
          return Center(
            child: Text(
              l.noAthletesInGroup,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 14),
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
                    l.groupOverview,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    group.name,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            // Chart mode toggle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: _ChartModeToggle(l: l),
            ),
            // Chart
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildChart(stats, chartMode, l),
            ),
            const SizedBox(height: 16),
            // Athlete stats list
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: stats.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) =>
                    _buildAthleteRow(stats[index], l),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildChart(
      List<GroupAthleteStats> stats, int chartMode, AppLocalizations l) {
    final hasData = stats.any((s) => chartMode == 0
        ? s.athlete.baselineCmjHeight != null
        : s.latestRsiScore != null);

    if (!hasData) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Text(
          l.noDataAvailable,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
      );
    }

    final barColor =
        chartMode == 0 ? AppColors.brand : const Color(0xFFF59E0B);

    final values = stats
        .map((s) => chartMode == 0
            ? (s.athlete.baselineCmjHeight ?? 0)
            : (s.latestRsiScore ?? 0))
        .toList();

    final maxVal = values.reduce((a, b) => a > b ? a : b);
    final yMax = maxVal > 0 ? maxVal * 1.2 : 1.0;

    return Container(
      height: 200,
      padding: const EdgeInsets.fromLTRB(0, 16, 8, 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: BarChart(
        BarChartData(
          maxY: yMax,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => AppColors.card,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final athlete = stats[group.x].athlete;
                final value = chartMode == 0
                    ? '${rod.toY.toStringAsFixed(1)} cm'
                    : rod.toY.toStringAsFixed(2);
                return BarTooltipItem(
                  '${athlete.name}\n$value',
                  const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                );
              },
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(
              color: AppColors.borderSubtle,
              strokeWidth: 0.5,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                getTitlesWidget: (value, _) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= stats.length) {
                    return const SizedBox.shrink();
                  }
                  final name = stats[idx].athlete.name;
                  final label =
                      name.length > 6 ? '${name.substring(0, 6)}.' : name;
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
                getTitlesWidget: (value, _) => Text(
                  chartMode == 0
                      ? value.toStringAsFixed(0)
                      : value.toStringAsFixed(1),
                  style: const TextStyle(
                      color: AppColors.textTertiary, fontSize: 10),
                ),
              ),
            ),
          ),
          barGroups: List.generate(stats.length, (i) {
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: values[i],
                  color: barColor,
                  width: stats.length <= 4 ? 28 : 16,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildAthleteRow(GroupAthleteStats stats, AppLocalizations l) {
    final athlete = stats.athlete;
    final initials = athlete.name.isNotEmpty
        ? athlete.name
            .split(' ')
            .where((w) => w.isNotEmpty)
            .take(2)
            .map((w) => w[0].toUpperCase())
            .join()
        : '?';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          // Top row: avatar + name/weight
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.brand.withOpacity(0.15),
                  border: Border.all(color: AppColors.brand.withOpacity(0.3)),
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: AppColors.brand,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  athlete.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${athlete.weightKg.toStringAsFixed(0)} kg',
                style: const TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Divider
          Container(height: 1, color: AppColors.borderSubtle),
          const SizedBox(height: 12),
          // Bottom row: 3 metric columns
          Row(
            children: [
              Expanded(
                child: _metricCell(
                  label: l.cmjHeightLabel,
                  value: athlete.baselineCmjHeight != null
                      ? '${athlete.baselineCmjHeight!.toStringAsFixed(1)} cm'
                      : '-',
                  valueColor: AppColors.textPrimary,
                ),
              ),
              Container(
                width: 1,
                height: 32,
                color: AppColors.borderSubtle,
              ),
              Expanded(
                child: _metricCell(
                  label: l.latestRsi,
                  value: stats.latestRsiScore != null
                      ? stats.latestRsiScore!.toStringAsFixed(2)
                      : '-',
                  valueColor: AppColors.textPrimary,
                ),
              ),
              Container(
                width: 1,
                height: 32,
                color: AppColors.borderSubtle,
              ),
              Expanded(
                child: _metricCell(
                  label: l.cmjImprovement,
                  value: stats.cmjImprovementPercent != null
                      ? '${stats.cmjImprovementPercent! >= 0 ? '+' : ''}${stats.cmjImprovementPercent!.toStringAsFixed(1)}%'
                      : '-',
                  valueColor: stats.cmjImprovementPercent == null
                      ? AppColors.textSecondary
                      : (stats.cmjImprovementPercent! >= 0
                          ? const Color(0xFF34D399)
                          : const Color(0xFFEF4444)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metricCell({
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textTertiary,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ChartModeToggle extends ConsumerWidget {
  final AppLocalizations l;

  const _ChartModeToggle({required this.l});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(groupChartModeProvider);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ToggleItem(
              label: l.cmjHeightLabel,
              isActive: mode == 0,
              onTap: () =>
                  ref.read(groupChartModeProvider.notifier).state = 0,
            ),
          ),
          Expanded(
            child: _ToggleItem(
              label: l.latestRsi,
              isActive: mode == 1,
              onTap: () =>
                  ref.read(groupChartModeProvider.notifier).state = 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleItem extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ToggleItem({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color:
              isActive ? AppColors.brand.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? AppColors.brand : AppColors.textSecondary,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
