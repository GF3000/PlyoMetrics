import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme.dart';
import '../models/athlete.dart';
import '../models/jump_test.dart';
import '../providers/cmj_session_provider.dart';
import '../providers/management_providers.dart';
import 'cmj_video_trim_screen.dart';

/// Main CMJ Baseline screen. Orchestrates recording up to 3 jumps per athlete,
/// displays results with error margins, detects outliers, and saves baselines.
/// Supports round-robin multi-athlete testing via the athlete chip bar.
class CmjBaselineScreen extends ConsumerWidget {
  final List<Athlete> athletes;

  const CmjBaselineScreen({super.key, required this.athletes});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final session = ref.watch(cmjSessionProvider);
    final activeSession = session.activeSession;
    final activeAthlete = activeSession != null
        ? athletes.firstWhere((a) => a.id == activeSession.athleteId,
            orElse: () => athletes.first)
        : athletes.first;

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
            Text(
              activeSession?.athleteName ?? activeAthlete.name,
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
                // Athlete chip bar (multi-athlete mode only)
                if (session.isMultiAthlete) ...[
                  _AthleteChipBar(
                    sessions: session.orderedSessions,
                    activeAthleteId: session.activeAthleteId,
                    onSelect: (id) =>
                        ref.read(cmjSessionProvider.notifier).setActiveAthlete(id),
                  ),
                  const SizedBox(height: 16),
                ],

                // Instructions
                if ((activeSession?.jumps ?? []).isEmpty)
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
                if (session.jumps.length < 3 && activeSession?.saved != true)
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
                    athlete: activeAthlete,
                  ),
                ],
              ],
            ),
          ),

          // Footer: save button(s)
          if (session.canSave || session.anySaveable)
            _SaveFooter(
              session: session,
              activeAthlete: activeAthlete,
              athletes: athletes,
              onSaveActive: () => _saveAthleteSession(
                context,
                ref,
                activeSession!,
                activeAthlete,
                popOnDone: !session.isMultiAthlete,
              ),
              onSaveAll: session.isMultiAthlete
                  ? () => _saveAll(context, ref, session)
                  : null,
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

  Future<void> _saveAthleteSession(
    BuildContext context,
    WidgetRef ref,
    AthleteSession athleteSession,
    Athlete athlete, {
    required bool popOnDone,
  }) async {
    final l = AppLocalizations.of(context)!;
    final jumpCount = athleteSession.jumps.length;

    if (athleteSession.validJumpCount < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.notEnoughValidJumpsToSave)),
      );
      return;
    }

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

    final service = ref.read(isarServiceProvider);

    final validJumps = [
      for (int i = 0; i < athleteSession.jumps.length; i++)
        if (!athleteSession.outlierFlags[i]) athleteSession.jumps[i],
    ];
    final avgFlightTimeMs = validJumps.isEmpty
        ? 0.0
        : validJumps.map((j) => j.flightTimeMs).reduce((a, b) => a + b) /
            validJumps.length;

    final test = JumpTest()
      ..athleteId = athlete.id
      ..testType = 'cmj_baseline'
      ..timestamp = DateTime.now()
      ..takeoffFrame = 0
      ..landingFrame = 0
      ..fps = athleteSession.jumps.isNotEmpty ? athleteSession.jumps.first.fps : 0
      ..flightTimeMs = avgFlightTimeMs
      ..heightCm = athleteSession.averageHeightCm!
      ..deltaHCm = athleteSession.propagatedErrorCm!
      ..isOutlier = false;

    await service.saveJumpTests([test]);
    await service.updateAthleteBaseline(
      athlete.id,
      athleteSession.averageHeightCm!,
      baselineDate: DateTime.now(),
    );

    ref.read(cmjSessionProvider.notifier).markSaved(athlete.id);

    // Keep activeAthleteProvider in sync for the dashboard
    final globalActive = ref.read(activeAthleteProvider);
    if (globalActive?.id == athlete.id) {
      final updatedAthlete = await service.db.athletes.get(athlete.id);
      if (updatedAthlete != null) {
        ref.read(activeAthleteProvider.notifier).state = updatedAthlete;
      }
    }

    if (popOnDone && context.mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _saveAll(
    BuildContext context,
    WidgetRef ref,
    CmjSessionState session,
  ) async {
    final l = AppLocalizations.of(context)!;
    final toSave = session.orderedSessions
        .where((s) => s.canSave && !s.saved)
        .toList();

    for (final athleteSession in toSave) {
      final athlete = athletes.firstWhere(
        (a) => a.id == athleteSession.athleteId,
      );
      await _saveAthleteSession(
        context,
        ref,
        athleteSession,
        athlete,
        popOnDone: false,
      );
      if (!context.mounted) return;
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.allBaselinesSaved)),
      );
      ref.read(cmjSessionProvider.notifier).reset();
      Navigator.of(context).pop();
    }
  }
}

// ── Athlete Chip Bar ──

class _AthleteChipBar extends StatelessWidget {
  final List<AthleteSession> sessions;
  final int? activeAthleteId;
  final void Function(int athleteId) onSelect;

  const _AthleteChipBar({
    required this.sessions,
    required this.activeAthleteId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: sessions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final s = sessions[index];
          final isActive = s.athleteId == activeAthleteId;
          final label = '${s.athleteName} (${s.validJumpCount}/3)';

          if (s.saved) {
            return _SavedChip(label: s.athleteName);
          }

          return FilterChip(
            label: Text(
              label,
              style: TextStyle(
                color: isActive ? AppColors.brand : AppColors.textSecondary,
                fontWeight:
                    isActive ? FontWeight.w600 : FontWeight.w400,
                fontSize: 13,
              ),
            ),
            selected: isActive,
            onSelected: (_) => onSelect(s.athleteId),
            backgroundColor: AppColors.card,
            selectedColor: AppColors.brand.withAlpha(20),
            side: BorderSide(
              color: isActive ? AppColors.brand : AppColors.borderLight,
            ),
            showCheckmark: false,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
          );
        },
      ),
    );
  }
}

class _SavedChip extends StatelessWidget {
  final String label;
  const _SavedChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: const Icon(Icons.check_circle, size: 16, color: Colors.green),
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.green,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: Colors.green.withAlpha(20),
      side: BorderSide(color: Colors.green.withAlpha(80)),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
    );
  }
}

// ── Save Footer ──

class _SaveFooter extends StatelessWidget {
  final CmjSessionState session;
  final Athlete activeAthlete;
  final List<Athlete> athletes;
  final VoidCallback onSaveActive;
  final VoidCallback? onSaveAll;

  const _SaveFooter({
    required this.session,
    required this.activeAthlete,
    required this.athletes,
    required this.onSaveActive,
    this.onSaveAll,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final activeCanSave =
        session.canSave && session.activeSession?.saved != true;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(top: BorderSide(color: AppColors.borderLight)),
      ),
      child: session.isMultiAthlete
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (activeCanSave)
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: onSaveActive,
                      icon: const Icon(Icons.save),
                      label: Text(
                          l.saveAthleteBaseline(activeAthlete.name)),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.brand,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                if (activeCanSave && session.anySaveable)
                  const SizedBox(height: 8),
                if (session.anySaveable && onSaveAll != null)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: onSaveAll,
                      icon: const Icon(Icons.save_alt),
                      label: Text(l.saveAll),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.brand,
                        side: const BorderSide(color: AppColors.brand),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            )
          : FilledButton.icon(
              onPressed: onSaveActive,
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
    );
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
                '± ${jump.deltaHCm.toStringAsFixed(1)} cm',
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
  final Athlete? athlete;

  const _BaselineSummary({
    required this.averageHeight,
    required this.propagatedError,
    this.athlete,
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
                '± ${propagatedError.toStringAsFixed(1)} cm',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (athlete != null && athlete!.getPeakPower(averageHeight) != null)
            Center(
              child: Text(
                '${l.peakPower}: ${athlete!.getPeakPower(averageHeight)!.toStringAsFixed(1)} W',
                style: TextStyle(
                  color: AppColors.brand,
                  fontSize: 14,
                  shadows: [Shadow(color: AppColors.brand.withValues(alpha: 0.5), blurRadius: 10)],
                ),
              ),
            ),
          const SizedBox(height: 4),
          if (athlete != null && athlete!.getRelativePower(averageHeight) != null)
            Center(
              child: Text(
                '${l.relativePowerLabel}: ${athlete!.getRelativePower(averageHeight)!.toStringAsFixed(1)} W/kg',
                style: TextStyle(
                  color: AppColors.brand,
                  fontSize: 14,
                  shadows: [Shadow(color: AppColors.brand.withValues(alpha: 0.5), blurRadius: 10)],
                ),
              ),
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
