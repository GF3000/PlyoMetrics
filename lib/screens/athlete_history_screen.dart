import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../core/theme.dart';
import '../models/jump_test.dart';
import '../providers/management_providers.dart';

// ── History entry types ──────────────────────────────────────────────────────

sealed class _HistoryEntry {}

class _SingleTestEntry extends _HistoryEntry {
  final JumpTest test;
  _SingleTestEntry(this.test);
}

class _AsymmetryPairEntry extends _HistoryEntry {
  final JumpTest left;
  final JumpTest right;
  final double asymmetryPct; // signed: positive = right stronger
  _AsymmetryPairEntry({
    required this.left,
    required this.right,
    required this.asymmetryPct,
  });
}

// ── Screen ───────────────────────────────────────────────────────────────────

class AthleteHistoryScreen extends ConsumerWidget {
  const AthleteHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final athlete = ref.watch(activeAthleteProvider);
    final historyAsync = ref.watch(athleteJumpHistoryProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.performanceHistory,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (athlete != null)
                    Text(
                      athlete.name,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: historyAsync.when(
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.brand)),
            error: (err, stack) => Center(child: Text(l.errorWithMessage(err.toString()))),
            data: (tests) {
              final entries = _buildEntries(tests);

              if (entries.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.history, size: 48, color: AppColors.textTertiary.withAlpha(100)),
                      const SizedBox(height: 16),
                      Text(
                        l.noJumpRecordsYet,
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: entries.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  return switch (entry) {
                    _SingleTestEntry e => _buildSingleRow(context, ref, l, e.test),
                    _AsymmetryPairEntry e => _buildAsymmetryRow(context, ref, l, e),
                  };
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // Builds the display list: groups asymmetry pairs, keeps others as-is.
  List<_HistoryEntry> _buildEntries(List<JumpTest> tests) {
    final grouped = <int, List<JumpTest>>{};
    final entries = <_HistoryEntry>[];
    final asymmetryIndices = <int>{};

    // Group asymmetry tests by session id
    for (int i = 0; i < tests.length; i++) {
      final t = tests[i];
      if (t.testType == 'asymmetry') {
        asymmetryIndices.add(i);
        final sid = t.asymmetrySessionId ?? t.id;
        grouped.putIfAbsent(sid, () => []).add(t);
      }
    }

    // Build entries list in original order (desc by timestamp)
    final seenSessionIds = <int>{};
    for (final test in tests) {
      if (test.testType != 'asymmetry') {
        entries.add(_SingleTestEntry(test));
        continue;
      }

      final sid = test.asymmetrySessionId ?? test.id;
      if (seenSessionIds.contains(sid)) continue;
      seenSessionIds.add(sid);

      final pair = grouped[sid] ?? [];
      final leftList = pair.where((t) => t.leg == 'left').toList();
      final rightList = pair.where((t) => t.leg == 'right').toList();

      if (leftList.isEmpty || rightList.isEmpty) {
        // Incomplete pair — show individually
        for (final t in pair) {
          entries.add(_SingleTestEntry(t));
        }
        continue;
      }

      final leftH = leftList.first.heightCm;
      final rightH = rightList.first.heightCm;
      final maxH = leftH > rightH ? leftH : rightH;
      final pct = maxH > 0 ? (rightH - leftH) / maxH * 100 : 0.0;

      entries.add(_AsymmetryPairEntry(
        left: leftList.first,
        right: rightList.first,
        asymmetryPct: pct,
      ));
    }

    return entries;
  }

  // ── Single-test row ────────────────────────────────────────────────────────

  Widget _buildSingleRow(BuildContext context, WidgetRef ref, AppLocalizations l, JumpTest test) {
    final dateStr = DateFormat('MMM dd, yyyy • HH:mm', l.localeName).format(test.timestamp);
    final bool isFatigueTest = test.testType == 'fatigue' && test.baselineAtTest != null;
    double? fatiguePercent;
    if (isFatigueTest) {
      fatiguePercent = ((test.baselineAtTest! - test.heightCm) / test.baselineAtTest!) * 100;
    }

    return Dismissible(
      key: ValueKey('single_${test.id}'),
      direction: DismissDirection.endToStart,
      background: _deleteBg(),
      confirmDismiss: (_) => _confirmDelete(context, l, _localizedTestTag(l, test.testType), dateStr),
      onDismissed: (_) async {
        final updated = await ref.read(isarServiceProvider).deleteJumpTest(test.id);
        if (updated != null && ref.read(activeAthleteProvider)?.id == updated.id) {
          ref.read(activeAthleteProvider.notifier).state = updated;
        }
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showJumpDetails(context, test, fatiguePercent),
          child: _card(
            tag: _localizedTestTag(l, test.testType),
            tagColor: AppColors.brand,
            dateStr: dateStr,
            primary: test.testType == 'rsi' && test.rsiScore != null
                ? test.rsiScore!.toStringAsFixed(2)
                : '${test.heightCm.toStringAsFixed(1)} cm',
            secondary: isFatigueTest && fatiguePercent != null
                ? Text(
                    l.fatiguePercent(fatiguePercent >= 0 ? '-' : '+', fatiguePercent.abs().toStringAsFixed(0)),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _fatigueColor(fatiguePercent),
                    ),
                  )
                : test.testType == 'rsi' && test.deltaRsi != null
                    ? Text(
                        '±${test.deltaRsi!.toStringAsFixed(2)} RSI',
                        style: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
                      )
                    : Text(
                        '±${test.deltaHCm.toStringAsFixed(1)} cm',
                        style: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
                      ),
          ),
        ),
      ),
    );
  }

  // ── Asymmetry pair row ─────────────────────────────────────────────────────

  Widget _buildAsymmetryRow(BuildContext context, WidgetRef ref, AppLocalizations l, _AsymmetryPairEntry entry) {
    final pct = entry.asymmetryPct;
    final absPct = pct.abs().round();
    final sign = pct >= 0 ? '+' : '-';
    final dateStr = DateFormat('MMM dd, yyyy • HH:mm', l.localeName)
        .format(entry.left.timestamp.isBefore(entry.right.timestamp)
            ? entry.left.timestamp
            : entry.right.timestamp);
    final legLabel = pct >= 0 ? l.rightStrongerLabel : l.leftStrongerLabel;
    final pctColor = _asymmetryColor(pct.abs());

    return Dismissible(
      key: ValueKey('asym_${entry.left.asymmetrySessionId ?? entry.left.id}'),
      direction: DismissDirection.endToStart,
      background: _deleteBg(),
      confirmDismiss: (_) => _confirmDelete(context, l, 'ASYMMETRY', dateStr),
      onDismissed: (_) async {
        // Delete both legs; each call recalculates asymmetry
        final service = ref.read(isarServiceProvider);
        await service.deleteJumpTest(entry.left.id);
        final updated = await service.deleteJumpTest(entry.right.id);
        if (updated != null && ref.read(activeAthleteProvider)?.id == updated.id) {
          ref.read(activeAthleteProvider.notifier).state = updated;
        }
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showAsymmetryDetails(context, l, entry),
          child: _card(
            tag: l.asymmetricTest.toUpperCase(),
            tagColor: const Color(0xFF8B5CF6),
            dateStr: dateStr,
            primary: '$sign$absPct%',
            primaryColor: pctColor,
            secondary: Text(
              legLabel,
              style: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
            ),
          ),
        ),
      ),
    );
  }

  // ── Card shell ─────────────────────────────────────────────────────────────

  Widget _card({
    required String tag,
    required Color tagColor,
    required String dateStr,
    required String primary,
    Color? primaryColor,
    required Widget secondary,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: tagColor.withAlpha(30),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: tagColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  dateStr,
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                primary,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: primaryColor ?? Colors.white,
                ),
              ),
              secondary,
            ],
          ),
        ],
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Widget _deleteBg() => Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade700,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      );

  Future<bool> _confirmDelete(BuildContext context, AppLocalizations l, String tag, String dateStr) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.card,
            title: Text(l.deleteJump, style: const TextStyle(color: Colors.white)),
            content: Text(
              l.confirmDeleteRecord(tag, dateStr),
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(l.cancel)),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text(l.delete, style: TextStyle(color: Colors.red.shade400)),
              ),
            ],
          ),
        ) ??
        false;
  }

  String _localizedTestTag(AppLocalizations l, String testType) {
    switch (testType) {
      case 'cmj_baseline':
        return l.testTagCmjBaseline;
      case 'fatigue':
        return l.testTagFatigue;
      case 'rsi':
        return l.testTagRsi;
      default:
        return testType.replaceAll('_', ' ').toUpperCase();
    }
  }

  Color _fatigueColor(double percent) {
    if (percent <= 5) return const Color(0xFF4ADE80);
    if (percent <= 10) return const Color(0xFFFACC15);
    return const Color(0xFFEF4444);
  }

  Color _asymmetryColor(double absPct) {
    if (absPct < 5) return const Color(0xFF4ADE80);
    if (absPct < 10) return const Color(0xFFFACC15);
    if (absPct < 15) return const Color(0xFFF97316);
    return const Color(0xFFEF4444);
  }

  // ── Detail sheets ──────────────────────────────────────────────────────────

  void _showJumpDetails(BuildContext context, JumpTest test, double? fatiguePercent) {
    final l = AppLocalizations.of(context)!;
    final rawDate = DateFormat('EEEE, MMM dd yyyy • HH:mm:ss', l.localeName).format(test.timestamp);
    final dateStr = rawDate[0].toUpperCase() + rawDate.substring(1);
    final isFatigueTest = test.testType == 'fatigue' && test.baselineAtTest != null;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => Container(
        decoration: const BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _sheetHandle(),
            const SizedBox(height: 16),
            Row(
              children: [
                _tagBadge(_localizedTestTag(l, test.testType), AppColors.brand),
                const Spacer(),
                if (isFatigueTest && fatiguePercent != null)
                  Text(
                    '${fatiguePercent >= 0 ? '-' : '+'}${fatiguePercent.abs().toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _fatigueColor(fatiguePercent),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(dateStr, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            ),
            const SizedBox(height: 20),
            _buildDetailGrid(sheetContext, test),
            if (isFatigueTest) ...[
              const SizedBox(height: 20),
              _buildComparisonChart(context, test.baselineAtTest!, test.heightCm),
            ],
          ],
        ),
      ),
    );
  }

  void _showAsymmetryDetails(BuildContext context, AppLocalizations l, _AsymmetryPairEntry entry) {
    final pct = entry.asymmetryPct;
    final absPct = pct.abs().round();
    final sign = pct >= 0 ? '+' : '-';
    final rawDate = DateFormat('EEEE, MMM dd yyyy • HH:mm:ss', l.localeName)
        .format(entry.left.timestamp.isBefore(entry.right.timestamp)
            ? entry.left.timestamp
            : entry.right.timestamp);
    final dateStr = rawDate[0].toUpperCase() + rawDate.substring(1);
    final pctColor = _asymmetryColor(pct.abs());
    final statusLabel = absPct < 5
        ? l.asymmetryPerfect
        : absPct < 10
            ? l.asymmetryGood
            : absPct < 15
                ? l.asymmetryCaution
                : l.asymmetryRisk;

    // Average error for the pair
    final avgError = (entry.left.deltaHCm + entry.right.deltaHCm) / 2;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => Container(
        decoration: const BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _sheetHandle(),
            const SizedBox(height: 16),
            Row(
              children: [
                _tagBadge(l.asymmetricTest.toUpperCase(), const Color(0xFF8B5CF6)),
                const Spacer(),
                Text(
                  '$sign$absPct%',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: pctColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(dateStr, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            ),
            const SizedBox(height: 20),

            // Detail grid
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _detailCell(sheetContext, l.leftLeg, '${entry.left.heightCm.toStringAsFixed(1)} cm'),
                _detailCell(sheetContext, l.rightLeg, '${entry.right.heightCm.toStringAsFixed(1)} cm'),
                _detailCell(sheetContext, l.detailErrorMargin, '±${avgError.toStringAsFixed(1)} cm'),
                _detailCell(sheetContext, l.asymmetryPct, '$sign$absPct%', valueColor: pctColor),
              ],
            ),

            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: pctColor.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: pctColor.withAlpha(60)),
              ),
              child: Text(
                statusLabel,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: pctColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sheetHandle() => Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.textTertiary.withAlpha(80),
          borderRadius: BorderRadius.circular(2),
        ),
      );

  Widget _tagBadge(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withAlpha(30),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: color,
            letterSpacing: 0.5,
          ),
        ),
      );

  Widget _detailCell(BuildContext context, String label, String value, {Color? valueColor}) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 52) / 2,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textTertiary,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: valueColor ?? AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailGrid(BuildContext context, JumpTest test) {
    final l = AppLocalizations.of(context)!;
    final isRsi = test.testType == 'rsi';
    final items = <_DetailItem>[
      _DetailItem(l.detailHeight, '${test.heightCm.toStringAsFixed(1)} cm'),
      _DetailItem(l.detailFlightTime, '${test.flightTimeMs.toStringAsFixed(1)} ms'),
      _DetailItem(l.detailFps, test.fps.toStringAsFixed(0)),
      if (isRsi && test.deltaRsi != null)
        _DetailItem(l.detailRsiError, '±${test.deltaRsi!.toStringAsFixed(2)}')
      else
        _DetailItem(l.detailErrorMargin, '±${test.deltaHCm.toStringAsFixed(1)} cm'),
      if (isRsi && test.contactTimeMs != null)
        _DetailItem(l.detailContactTime, '${test.contactTimeMs!.toStringAsFixed(1)} ms'),
      if (isRsi && test.rsiScore != null)
        _DetailItem(l.detailRsiScore, test.rsiScore!.toStringAsFixed(2)),
      if (test.baselineAtTest != null)
        _DetailItem(l.detailBaselineAtTest, '${test.baselineAtTest!.toStringAsFixed(1)} cm'),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: items
          .map((item) => _detailCell(context, item.label, item.value))
          .toList(),
    );
  }

  Widget _buildComparisonChart(BuildContext context, double baseline, double current) {
    final l = AppLocalizations.of(context)!;
    final maxVal = baseline > current ? baseline : current;
    final baselineRatio = maxVal > 0 ? baseline / maxVal : 0.0;
    final currentRatio = maxVal > 0 ? current / maxVal : 0.0;

    return Container(
      height: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: _buildBar(
              label: l.baseline,
              value: '${baseline.toStringAsFixed(1)} cm',
              ratio: baselineRatio,
              color: AppColors.brand.withAlpha(102),
              borderColor: AppColors.brand,
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: _buildBar(
              label: l.current,
              value: '${current.toStringAsFixed(1)} cm',
              ratio: currentRatio,
              color: AppColors.brand,
              borderColor: const Color(0xFF06B6D4),
              glow: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar({
    required String label,
    required String value,
    required double ratio,
    required Color color,
    required Color borderColor,
    bool glow = false,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          value,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: ratio.clamp(0.05, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  border: Border(top: BorderSide(color: borderColor, width: 2)),
                  boxShadow: glow
                      ? [BoxShadow(color: AppColors.brand.withAlpha(77), blurRadius: 8)]
                      : null,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ],
    );
  }
}

class _DetailItem {
  final String label;
  final String value;
  const _DetailItem(this.label, this.value);
}
