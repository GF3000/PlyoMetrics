import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../models/athlete.dart';
import '../models/jump_test.dart';
import '../providers/cmj_session_provider.dart';
import '../providers/management_providers.dart';
import '../services/isar_service.dart';
import 'cmj_video_trim_screen.dart';

class FatigueTestScreen extends ConsumerStatefulWidget {
  const FatigueTestScreen({super.key});

  @override
  ConsumerState<FatigueTestScreen> createState() => _FatigueTestScreenState();
}

class _FatigueTestScreenState extends ConsumerState<FatigueTestScreen>
    with SingleTickerProviderStateMixin {
  JumpResult? _jumpResult;
  double? _fatiguePercent;
  bool _isSaving = false;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  double get _baseline =>
      ref.read(activeAthleteProvider)!.baselineCmjHeight!;

  Future<void> _recordJump() async {
    final result = await Navigator.of(context).push<JumpResult>(
      MaterialPageRoute(builder: (_) => const CmjVideoTrimScreen()),
    );
    if (result == null || !mounted) return;

    final baseline = _baseline;

    setState(() {
      _jumpResult = result;
      _fatiguePercent = ((baseline - result.heightCm) / baseline) * 100;
    });

    // PB detection
    if (result.heightCm > baseline) {
      _showPbDialog(result.heightCm);
    }
  }

  void _showPbDialog(double newHeight) {
    final l = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: const Color(0xE60F172A),
      builder: (ctx) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 340),
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.brand.withValues(alpha: 0.5),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 24,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.brand.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.star_rounded,
                    size: 32,
                    color: AppColors.brand,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l.newPersonalBest,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Builder(builder: (_) {
                  final heightStr = '${newHeight.toStringAsFixed(1)}cm';
                  final fullMsg = l.pbDialogMessage(newHeight.toStringAsFixed(1));
                  final parts = fullMsg.split(heightStr);
                  return RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                      children: [
                        TextSpan(text: parts[0]),
                        TextSpan(
                          text: heightStr,
                          style: const TextStyle(
                            color: AppColors.brand,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: parts.length > 1 ? parts[1] : '',
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brand,
                      foregroundColor: const Color(0xFF0F172A),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () async {
                      final athlete = ref.read(activeAthleteProvider)!;
                      await IsarService.instance.updateAthleteBaseline(
                        athlete.id,
                        newHeight,
                      );
                      final updated = await IsarService
                          .instance.db.athletes
                          .get(athlete.id);
                      if (updated != null) {
                        ref.read(activeAthleteProvider.notifier).state =
                            updated;
                      }
                      if (mounted) {
                        setState(() {
                          _fatiguePercent =
                              ((newHeight - _jumpResult!.heightCm) /
                                      newHeight) *
                                  100;
                        });
                        Navigator.of(ctx).pop();
                      }
                    },
                    child: Text(
                      l.updateBaseline,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: Text(
                      l.dismiss,
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveTest() async {
    if (_jumpResult == null) return;
    setState(() => _isSaving = true);

    final athlete = ref.read(activeAthleteProvider)!;
    final test = JumpTest()
      ..athleteId = athlete.id
      ..testType = 'fatigue'
      ..timestamp = DateTime.now()
      ..takeoffFrame = _jumpResult!.takeoffFrame
      ..landingFrame = _jumpResult!.landingFrame
      ..fps = _jumpResult!.fps
      ..flightTimeMs = _jumpResult!.flightTimeMs
      ..heightCm = _jumpResult!.heightCm
      ..deltaHCm = _jumpResult!.deltaHCm
      ..baselineAtTest = athlete.baselineCmjHeight;

    await ref.read(isarServiceProvider).saveJumpTests([test]);

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _discard() {
    setState(() {
      _jumpResult = null;
      _fatiguePercent = null;
    });
  }

  ({String label, Color color}) get _fatigueStatus {
    final p = _fatiguePercent ?? 0;
    if (p < 5) {
      return (label: 'Optimal', color: const Color(0xFF4ADE80));
    } else if (p <= 10) {
      return (label: 'Moderate Fatigue', color: const Color(0xFFFACC15));
    } else {
      return (label: 'High Fatigue', color: const Color(0xFFEF4444));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final athlete = ref.watch(activeAthleteProvider)!;
    final baseline = athlete.baselineCmjHeight!;
    final hasResult = _jumpResult != null;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(l.fatigueTest),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(l),
              const SizedBox(height: 20),
              _buildStatsGrid(l, baseline),
              if (hasResult) ...[
                const SizedBox(height: 16),
                _buildFatigueCard(l),
                const SizedBox(height: 16),
                _buildBarVisualization(l, baseline),
              ],
              const SizedBox(height: 24),
              if (!hasResult) _buildRecordButton(l),
              if (hasResult) _buildActionButtons(l),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.fatigueTest,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l.countermovementJumpCMJ,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        AnimatedBuilder(
          animation: _pulseController,
          builder: (_, __) => Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.brand
                  .withValues(alpha: 0.4 + _pulseController.value * 0.6),
              boxShadow: [
                BoxShadow(
                  color: AppColors.brand
                      .withValues(alpha: _pulseController.value * 0.4),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(AppLocalizations l, double baseline) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            label: l.currentJump,
            value: _jumpResult != null
                ? _jumpResult!.heightCm.toStringAsFixed(1)
                : '--',
            unit: 'cm',
            valueColor: AppColors.brand,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            label: l.baselineMax,
            value: baseline.toStringAsFixed(1),
            unit: 'cm',
            valueColor: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required String unit,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: valueColor,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: const TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFatigueCard(AppLocalizations l) {
    final status = _fatigueStatus;
    final percent = _fatiguePercent ?? 0;
    final displayPercent = percent.abs().toStringAsFixed(0);
    final localizedLabel = percent <= 5
        ? l.optimal
        : percent <= 10
            ? l.moderateFatigue
            : l.highFatigue;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.brand.withValues(alpha: 0.2),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Text(
            l.fatigueStatus,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$displayPercent%',
            style: TextStyle(
              color: AppColors.brand,
              fontSize: 48,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            localizedLabel,
            style: TextStyle(
              color: status.color,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            percent <= 5
                ? l.fatigueOptimalMessage
                : percent <= 10
                    ? l.fatigueModerateMessage
                    : l.fatigueHighMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textTertiary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarVisualization(AppLocalizations l, double baseline) {
    final current = _jumpResult?.heightCm ?? 0;
    final maxVal = baseline > current ? baseline : current;
    final baselineRatio = maxVal > 0 ? baseline / maxVal : 0.0;
    final currentRatio = maxVal > 0 ? current / maxVal : 0.0;

    return Container(
      height: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: _buildBar(
              label: l.baseline,
              ratio: baselineRatio,
              color: AppColors.brand.withValues(alpha: 0.4),
              borderColor: AppColors.brand,
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: _buildBar(
              label: l.current,
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
    required double ratio,
    required Color color,
    required Color borderColor,
    bool glow = false,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: ratio.clamp(0.05, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(4)),
                  border: Border(
                    top: BorderSide(color: borderColor, width: 2),
                  ),
                  boxShadow: glow
                      ? [
                          BoxShadow(
                            color: AppColors.brand.withValues(alpha: 0.3),
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

  Widget _buildRecordButton(AppLocalizations l) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.brand,
        foregroundColor: const Color(0xFF0F172A),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 4,
        shadowColor: AppColors.brand.withValues(alpha: 0.3),
      ),
      onPressed: _recordJump,
      icon: const Icon(Icons.videocam_rounded),
      label: Text(
        l.recordDailyJump,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildActionButtons(AppLocalizations l) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.brand,
            foregroundColor: const Color(0xFF0F172A),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 4,
            shadowColor: AppColors.brand.withValues(alpha: 0.1),
          ),
          onPressed: _isSaving ? null : _saveTest,
          child: _isSaving
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF0F172A),
                  ),
                )
              : Text(
                  l.saveTest,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: _isSaving ? null : _discard,
          child: Text(
            l.discardResult,
            style: TextStyle(
              color: AppColors.textTertiary,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
