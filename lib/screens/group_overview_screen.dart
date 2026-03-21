import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme.dart';
import '../l10n/app_localizations.dart';
import '../providers/management_providers.dart';

// Deterministic color palette for athlete markers
const _athletePalette = [
  Color(0xFF25C0F4), // brand cyan
  Color(0xFF34D399), // green
  Color(0xFFF59E0B), // amber
  Color(0xFFEF4444), // red
  Color(0xFF8B5CF6), // purple
  Color(0xFFEC4899), // pink
  Color(0xFF06B6D4), // teal
  Color(0xFFF97316), // orange
];

Color _colorForAthleteId(int id) => _athletePalette[id % _athletePalette.length];

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
              child: _buildChart(context, stats, chartMode, l),
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

  Widget _buildChart(BuildContext context, List<GroupAthleteStats> stats,
      int chartMode, AppLocalizations l) {
    if (chartMode == 1) {
      return _buildRsiScatterChart(context, stats, l);
    }
    return _buildCmjBarChart(stats, l);
  }

  Widget _buildCmjBarChart(List<GroupAthleteStats> stats, AppLocalizations l) {
    final hasData = stats.any((s) => s.athlete.baselineCmjHeight != null);

    if (!hasData) {
      return _emptyChartContainer(l);
    }

    final values =
        stats.map((s) => s.athlete.baselineCmjHeight ?? 0).toList();
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
                return BarTooltipItem(
                  '${athlete.name}\n${rod.toY.toStringAsFixed(1)} cm',
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
                  value.toStringAsFixed(0),
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
                  color: AppColors.brand,
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

  Widget _buildRsiScatterChart(
      BuildContext context, List<GroupAthleteStats> stats, AppLocalizations l) {
    final scatterData = _filterScatterData(stats);
    if (scatterData.isEmpty) return _emptyChartContainer(l);

    return Stack(
      children: [
        Container(
          height: 200,
          padding: const EdgeInsets.fromLTRB(0, 16, 8, 8),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: _buildScatterChartCore(scatterData, l),
        ),
        Positioned(
          top: 8,
          right: 12,
          child: InkWell(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                fullscreenDialog: true,
                builder: (_) => _FullscreenRsiChart(stats: stats, l: l),
              ),
            ),
            borderRadius: BorderRadius.circular(4),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(
                Icons.fullscreen,
                color: AppColors.textTertiary,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _emptyChartContainer(AppLocalizations l) {
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
                  color: AppColors.brand.withValues(alpha: 0.15),
                  border: Border.all(color: AppColors.brand.withValues(alpha: 0.3)),
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
                '${athlete.heightCm != null ? '${athlete.heightCm!.toInt()} cm' : '— cm'} | ${athlete.weightKg != null ? '${athlete.weightKg!.toInt()} kg' : '— kg'}',
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
                  label: l.relativePower,
                  value: athlete.baselineCmjHeight != null
                      ? (athlete.getRelativePower(athlete.baselineCmjHeight!) != null
                          ? '${athlete.getRelativePower(athlete.baselineCmjHeight!)!.toStringAsFixed(1)} W/kg'
                          : '— W/kg')
                      : '-',
                  valueColor: AppColors.textPrimary,
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

// ---------------------------------------------------------------------------
// Shared scatter chart helpers
// ---------------------------------------------------------------------------

typedef _ScatterEntry = ({GroupAthleteStats stat, double contact, double flight});

List<_ScatterEntry> _filterScatterData(List<GroupAthleteStats> stats) {
  final result = <_ScatterEntry>[];
  for (final s in stats) {
    if (s.latestContactTimeMs != null && s.latestFlightTimeMs != null) {
      result.add((
        stat: s,
        contact: s.latestContactTimeMs!,
        flight: s.latestFlightTimeMs!,
      ));
    }
  }
  return result;
}

Widget _buildScatterChartCore(
  List<_ScatterEntry> scatterData,
  AppLocalizations l, {
  double markerRadius = 13,
  double axisFontSize = 10,
}) {
  final contacts = scatterData.map((d) => d.contact).toList();
  final flights = scatterData.map((d) => d.flight).toList();

  final dataMinX = contacts.reduce((a, b) => a < b ? a : b);
  final dataMaxX = contacts.reduce((a, b) => a > b ? a : b);
  final dataMinY = flights.reduce((a, b) => a < b ? a : b);
  final dataMaxY = flights.reduce((a, b) => a > b ? a : b);

  // Averages for crosshair lines
  final avgX = contacts.reduce((a, b) => a + b) / contacts.length;
  final avgY = flights.reduce((a, b) => a + b) / flights.length;

  // Dynamic padding: at least 40ms or 15% of range to prevent marker clipping
  const kMinPadMs = 40.0;
  final xRange = dataMaxX - dataMinX;
  final yRange = dataMaxY - dataMinY;
  final xPad = xRange > 0 ? max(xRange * 0.15, kMinPadMs) : kMinPadMs;
  final yPad = yRange > 0 ? max(yRange * 0.15, kMinPadMs) : kMinPadMs;

  var chartMinX = ((dataMinX - xPad) / 50).floor() * 50.0;
  if (chartMinX > dataMinX - 50.0) chartMinX -= 50.0;
  var chartMaxX = ((dataMaxX + xPad) / 50).ceil() * 50.0;
  if (chartMaxX < dataMaxX + 50.0) chartMaxX += 50.0;
  var chartMinY = ((dataMinY - yPad) / 50).floor() * 50.0;
  if (chartMinY > dataMinY - 50.0) chartMinY -= 50.0;
  var chartMaxY = ((dataMaxY + yPad) / 50).ceil() * 50.0;
  if (chartMaxY < dataMaxY + 50.0) chartMaxY += 50.0;

  // Shared titles config for both layers
  final titlesData = FlTitlesData(
    topTitles:
        const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    rightTitles:
        const AxisTitles(sideTitles: SideTitles(showTitles: false)),
  bottomTitles: AxisTitles(
    axisNameWidget: Text(
      l.contactTimeAxisMs,
      style: TextStyle(
          color: AppColors.textTertiary, fontSize: axisFontSize),
    ),
    axisNameSize: 24,
    sideTitles: SideTitles(
      showTitles: true,
      reservedSize: 32,
      interval: 50.0,
      getTitlesWidget: (value, _) => Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          value.toStringAsFixed(0),
          style: TextStyle(
              color: AppColors.textTertiary, fontSize: axisFontSize),
        ),
      ),
    ),
  ),
  leftTitles: AxisTitles(
    axisNameWidget: Text(
      l.flightTimeAxisMs,
      style: TextStyle(
          color: AppColors.textTertiary, fontSize: axisFontSize),
    ),
    axisNameSize: 24,
    sideTitles: SideTitles(
      showTitles: true,
      reservedSize: 48,
      interval: 50.0,
      getTitlesWidget: (value, _) => Text(
        value.toStringAsFixed(0),
        style: TextStyle(
            color: AppColors.textTertiary, fontSize: axisFontSize),
      ),
    ),
  ),
  );

  return Stack(
    children: [
      // Background layer: avg crosshair lines via LineChart
      LineChart(
        LineChartData(
          minX: chartMinX,
          maxX: chartMaxX,
          minY: chartMinY,
          maxY: chartMaxY,
          lineBarsData: [
            // Horizontal avg line
            LineChartBarData(
              spots: [
                FlSpot(chartMinX, avgY),
                FlSpot(chartMaxX, avgY),
              ],
              color: AppColors.textTertiary,
              barWidth: 0.8,
              dotData: const FlDotData(show: false),
              dashArray: [4, 4],
            ),
            // Vertical avg line
            LineChartBarData(
              spots: [
                FlSpot(avgX, chartMinY),
                FlSpot(avgX, chartMaxY),
              ],
              color: AppColors.textTertiary,
              barWidth: 0.8,
              dotData: const FlDotData(show: false),
              dashArray: [4, 4],
            ),
          ],
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: titlesData,
          lineTouchData: const LineTouchData(enabled: false),
        ),
      ),
      // Foreground layer: scatter dots with avatar initials
      ScatterChart(
        ScatterChartData(
          minX: chartMinX,
          maxX: chartMaxX,
          minY: chartMinY,
          maxY: chartMaxY,
          scatterSpots: scatterData.map((d) {
            final athlete = d.stat.athlete;
            final initial = athlete.name.isNotEmpty
                ? athlete.name[0].toUpperCase()
                : '?';
            return ScatterSpot(
              d.contact,
              d.flight,
              dotPainter: _InitialDotPainter(
                initial: initial,
                backgroundColor: _colorForAthleteId(athlete.id),
                radius: markerRadius,
              ),
            );
          }).toList(),
          scatterTouchData: ScatterTouchData(
            touchTooltipData: ScatterTouchTooltipData(
              getTooltipColor: (_) => AppColors.card,
              getTooltipItems: (touchedSpot) {
                final idx = scatterData.indexWhere(
                    (d) => d.contact == touchedSpot.x && d.flight == touchedSpot.y);
                if (idx < 0) return null;
                final name = scatterData[idx].stat.athlete.name;
                return ScatterTooltipItem(
                  '$name\n${touchedSpot.x.toStringAsFixed(0)} / ${touchedSpot.y.toStringAsFixed(0)} ms',
                  textStyle: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                );
              },
            ),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: const FlTitlesData(
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
        ),
      ),
    ],
  );
}

// ---------------------------------------------------------------------------
// Custom FlDotPainter: circle with athlete initial
// ---------------------------------------------------------------------------

class _InitialDotPainter extends FlDotPainter {
  final String initial;
  final Color backgroundColor;
  final double radius;

  _InitialDotPainter({
    required this.initial,
    required this.backgroundColor,
    this.radius = 13,
  });

  @override
  void draw(Canvas canvas, FlSpot spot, Offset offsetInCanvas) {
    // Filled circle
    canvas.drawCircle(
      offsetInCanvas,
      radius,
      Paint()..color = backgroundColor,
    );

    // Subtle border
    canvas.drawCircle(
      offsetInCanvas,
      radius,
      Paint()
        ..color = backgroundColor.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Initial text centered in circle
    final textPainter = TextPainter(
      text: TextSpan(
        text: initial,
        style: TextStyle(
          color: Colors.white,
          fontSize: radius * 0.9,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(
        offsetInCanvas.dx - textPainter.width / 2,
        offsetInCanvas.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  Size getSize(FlSpot spot) => Size.fromRadius(radius);

  @override
  Color get mainColor => backgroundColor;

  @override
  FlDotPainter lerp(FlDotPainter a, FlDotPainter b, double t) => b;

  @override
  List<Object?> get props => [initial, backgroundColor, radius];
}

// ---------------------------------------------------------------------------
// Fullscreen RSI Scatter Chart (landscape)
// ---------------------------------------------------------------------------

class _FullscreenRsiChart extends StatefulWidget {
  final List<GroupAthleteStats> stats;
  final AppLocalizations l;

  const _FullscreenRsiChart({required this.stats, required this.l});

  @override
  State<_FullscreenRsiChart> createState() => _FullscreenRsiChartState();
}

class _FullscreenRsiChartState extends State<_FullscreenRsiChart> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scatterData = _filterScatterData(widget.stats);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.l.rsiScatterTitle,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: scatterData.isEmpty
          ? Center(
              child: Text(
                widget.l.noDataAvailable,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 14),
              ),
            )
          : Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: _buildScatterChartCore(
                scatterData,
                widget.l,
                markerRadius: 16,
                axisFontSize: 12,
              ),
            ),
    );
  }
}

// ---------------------------------------------------------------------------
// Chart Mode Toggle
// ---------------------------------------------------------------------------

class _ChartModeToggle extends ConsumerWidget {
  final AppLocalizations l;

  const _ChartModeToggle({required this.l});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(groupChartModeProvider);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
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
              isActive ? AppColors.brand.withValues(alpha: 0.15) : Colors.transparent,
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
