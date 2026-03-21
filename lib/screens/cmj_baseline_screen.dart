import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme.dart';
import '../models/athlete.dart';
import '../models/jump_test.dart';
import '../providers/cmj_session_provider.dart';
import '../providers/management_providers.dart';
import 'cmj_video_trim_screen.dart';

/// Main CMJ Baseline screen. Orchestrates recording up to 3 jumps,
/// displays results with error margins, detects outliers, and saves
/// the baseline to Isar.
class CmjBaselineScreen extends ConsumerWidget {
  const CmjBaselineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final athlete = ref.watch(activeAthleteProvider);
    final session = ref.watch(cmjSessionProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.cmjBaseline,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            if (athlete != null)
              Text(
                athlete.name,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
              ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () {
            ref.read(cmjSessionProvider.notifier).reset();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Instructions
                if (session.jumps.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 32,
                          color: AppColors.brand,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l.cmjBaselineInstructions,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Jump cards
                for (int i = 0; i < session.jumps.length; i++) ...[
                  if (i > 0 || session.jumps.isEmpty) const SizedBox(height: 12),
                  _JumpCard(
                    index: i,
                    jump: session.jumps[i],
                    isOutlier: session.outlierFlags.length > i &&
                        session.outlierFlags[i],
                    onRemove: () =>
                        ref.read(cmjSessionProvider.notifier).removeJump(i),
                  ),
                ],

                const SizedBox(height: 16),

                // Record jump button
                if (session.jumps.length < 3)
                  OutlinedButton.icon(
                    onPressed: () => _recordJump(context, ref),
                    icon: const Icon(Icons.videocam),
                    label: Text(l.recordJumpNumber(session.jumps.length + 1)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.brand,
                      side: const BorderSide(color: AppColors.brand),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                // Summary
                if (session.averageHeightCm != null) ...[
                  const SizedBox(height: 24),
                  _BaselineSummary(
                    averageHeight: session.averageHeightCm!,
                    propagatedError: session.propagatedErrorCm!,
                  ),
                ],
              ],
            ),
          ),

          // Footer: Save button
          if (session.canSave)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.card,
                border: Border(
                  top: BorderSide(color: AppColors.borderLight),
                ),
              ),
              child: FilledButton.icon(
                onPressed: () => _saveBaseline(context, ref, session),
                icon: const Icon(Icons.save),
                label: Text(l.saveMeasurement),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.brand,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _recordJump(BuildContext context, WidgetRef ref) async {
    final result = await Navigator.of(context).push<JumpResult>(
      MaterialPageRoute(builder: (_) => const CmjVideoTrimScreen()),
    );
    if (result != null) {
      ref.read(cmjSessionProvider.notifier).addJump(result);
    }
  }

  Future<void> _saveBaseline(
    BuildContext context,
    WidgetRef ref,
    CmjSessionState session,
  ) async {
    final l = AppLocalizations.of(context)!;
    final jumpCount = session.jumps.length;
    if (jumpCount < 3) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.card,
          title: Text(
            l.incompleteBaseline,
            style: const TextStyle(color: Colors.white),
          ),
          content: Text(
            l.incompleteBaselineMessage,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(backgroundColor: AppColors.brand),
              child: Text(l.saveAnyway),
            ),
          ],
        ),
      );
      if (proceed != true) return;
    }

    final athlete = ref.read(activeAthleteProvider);
    if (athlete == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.noAthleteSelected)),
      );
      return;
    }

    final service = ref.read(isarServiceProvider);

    // Compute average flight time from valid (non-outlier) jumps
    final validJumps = [
      for (int i = 0; i < session.jumps.length; i++)
        if (!session.outlierFlags[i]) session.jumps[i],
    ];
    final avgFlightTimeMs = validJumps.isEmpty
        ? 0.0
        : validJumps.map((j) => j.flightTimeMs).reduce((a, b) => a + b) /
            validJumps.length;

    // Create a single JumpTest record for the average
    final test = JumpTest()
      ..athleteId = athlete.id
      ..testType = 'cmj_baseline'
      ..timestamp = DateTime.now()
      ..takeoffFrame = 0
      ..landingFrame = 0
      ..fps = session.jumps.isNotEmpty ? session.jumps.first.fps : 0
      ..flightTimeMs = avgFlightTimeMs
      ..heightCm = session.averageHeightCm!
      ..deltaHCm = session.propagatedErrorCm!
      ..isOutlier = false;

    await service.saveJumpTests([test]);
    await service.updateAthleteBaseline(
      athlete.id,
      session.averageHeightCm!,
      baselineDate: DateTime.now(),
    );

    ref.read(cmjSessionProvider.notifier).reset();

    // Refresh the active athlete to reflect the new baseline
    final updatedAthlete = await service.db.athletes.get(athlete.id);
    if (updatedAthlete != null) {
      ref.read(activeAthleteProvider.notifier).state = updatedAthlete;
    }

    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }
}

// ── Jump Card Widget ──

class _JumpCard extends StatelessWidget {
  final int index;
  final JumpResult jump;
  final bool isOutlier;
  final VoidCallback onRemove;

  const _JumpCard({
    required this.index,
    required this.jump,
    required this.isOutlier,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isOutlier ? Colors.amber.withAlpha(100) : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    l.jumpNumber(index + 1),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (isOutlier) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.withAlpha(30),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.amber.withAlpha(80)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.warning_amber,
                              size: 14, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            l.outlier,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.amber,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.close, size: 18),
                color: AppColors.textTertiary,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Height with error
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                jump.heightCm.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: isOutlier ? AppColors.textTertiary : AppColors.brand,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '\u00b1 ${jump.deltaHCm.toStringAsFixed(1)} cm',
                style: TextStyle(
                  fontSize: 14,
                  color: isOutlier
                      ? AppColors.textTertiary
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          // Flight time
          Text(
            l.flightTimeInfo(jump.flightTimeMs.toStringAsFixed(1), jump.fps.toStringAsFixed(0)),
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Baseline Summary Widget ──

class _BaselineSummary extends StatelessWidget {
  final double averageHeight;
  final double propagatedError;

  const _BaselineSummary({
    required this.averageHeight,
    required this.propagatedError,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.brand.withAlpha(60)),
        boxShadow: [
          BoxShadow(
            color: AppColors.brand.withAlpha(60),
            blurRadius: 20,
            spreadRadius: -4,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            l.calculatedAverage,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.brand,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                averageHeight.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '\u00b1 ${propagatedError.toStringAsFixed(1)} cm',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            l.outliersExcluded,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
