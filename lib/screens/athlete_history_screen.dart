import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../core/theme.dart';
import '../models/jump_test.dart';
import '../providers/management_providers.dart';

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
                    style: TextStyle(
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
        Expanded(child: historyAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.brand)),
      error: (err, stack) => Center(child: Text(l.errorWithMessage(err.toString()))),
      data: (tests) {
        if (tests.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.history, size: 48, color: AppColors.textTertiary.withAlpha(100)),
              const SizedBox(height: 16),
              Text(
                l.noJumpRecordsYet,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: tests.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final test = tests[index];
            final dateStr = DateFormat('MMM dd, yyyy • HH:mm', l.localeName).format(test.timestamp);

            // Calculate fatigue percentage for fatigue tests
            final bool isFatigueTest = test.testType == 'fatigue' && test.baselineAtTest != null;
            double? fatiguePercent;
            if (isFatigueTest) {
              fatiguePercent = ((test.baselineAtTest! - test.heightCm) / test.baselineAtTest!) * 100;
            }

            return Dismissible(
              key: ValueKey(test.id),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                decoration: BoxDecoration(
                  color: Colors.red.shade700,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              confirmDismiss: (_) async {
                return await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: AppColors.card,
                    title: Text(l.deleteJump,
                        style: const TextStyle(color: Colors.white)),
                    content: Text(
                      l.confirmDeleteRecord(_localizedTestTag(l, test.testType), dateStr),
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: Text(l.cancel),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        child: Text(l.delete,
                            style: TextStyle(color: Colors.red.shade400)),
                      ),
                    ],
                  ),
                ) ?? false;
              },
              onDismissed: (_) async {
                final updatedAthlete =
                    await ref.read(isarServiceProvider).deleteJumpTest(test.id);
                if (updatedAthlete != null &&
                    ref.read(activeAthleteProvider)?.id == updatedAthlete.id) {
                  ref.read(activeAthleteProvider.notifier).state = updatedAthlete;
                }
              },
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _showJumpDetails(context, test, fatiguePercent),
                  child: Container(
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
                                  color: AppColors.brand.withAlpha(30),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  _localizedTestTag(l, test.testType),
                                  style: const TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.brand,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                dateStr,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              test.testType == 'rsi' && test.rsiScore != null
                                  ? test.rsiScore!.toStringAsFixed(2)
                                  : '${test.heightCm.toStringAsFixed(1)} cm',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            if (isFatigueTest && fatiguePercent != null)
                              Text(
                                l.fatiguePercent(fatiguePercent >= 0 ? '-' : '+', fatiguePercent.abs().toStringAsFixed(0)),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _fatigueColor(fatiguePercent),
                                ),
                              )
                            else if (test.testType == 'rsi' && test.deltaRsi != null)
                              Text(
                                '\u00b1${test.deltaRsi!.toStringAsFixed(2)} RSI',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textTertiary,
                                ),
                              )
                            else
                              Text(
                                '\u00b1${test.deltaHCm.toStringAsFixed(1)} cm',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textTertiary,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    )),
      ],
    );
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
    if (percent <= 5) return const Color(0xFF4ADE80); // green
    if (percent <= 10) return const Color(0xFFFACC15); // yellow
    return const Color(0xFFEF4444); // red
  }

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
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textTertiary.withAlpha(80),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),

            // Title row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.brand.withAlpha(30),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _localizedTestTag(l, test.testType),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppColors.brand,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
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
              child: Text(
                dateStr,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Data grid
            _buildDetailGrid(sheetContext, test),

            // Bar chart for fatigue tests
            if (isFatigueTest) ...[
              const SizedBox(height: 20),
              _buildComparisonChart(context, test.baselineAtTest!, test.heightCm),
            ],
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
        _DetailItem(l.detailRsiError, '\u00b1${test.deltaRsi!.toStringAsFixed(2)}')
      else
        _DetailItem(l.detailErrorMargin, '\u00b1${test.deltaHCm.toStringAsFixed(1)} cm'),
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
      children: items.map((item) => SizedBox(
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
                item.label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textTertiary,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      )).toList(),
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
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
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
                  border: Border(
                    top: BorderSide(color: borderColor, width: 2),
                  ),
                  boxShadow: glow
                      ? [
                          BoxShadow(
                            color: AppColors.brand.withAlpha(77),
                            blurRadius: 8,
                          ),
                        ]
                      : null,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _DetailItem {
  final String label;
  final String value;
  const _DetailItem(this.label, this.value);
}
