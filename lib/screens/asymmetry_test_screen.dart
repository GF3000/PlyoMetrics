import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme.dart';
import '../l10n/app_localizations.dart';
import '../models/athlete.dart';
import '../models/jump_test.dart';
import '../providers/asymmetry_session_provider.dart';
import '../providers/cmj_session_provider.dart';
import '../providers/management_providers.dart';
import 'cmj_video_trim_screen.dart';

Color _asymmetryColor(double pct) {
  final abs = pct.abs();
  if (abs < 5) return Colors.green;
  if (abs < 10) return Colors.amber;
  if (abs < 15) return Colors.orange;
  return Colors.red;
}

String _asymmetryLabel(AppLocalizations l, double pct) {
  final abs = pct.abs();
  if (abs < 5) return l.asymmetryPerfect;
  if (abs < 10) return l.asymmetryGood;
  if (abs < 15) return l.asymmetryCaution;
  return l.asymmetryRisk;
}

class AsymmetryTestScreen extends ConsumerWidget {
  final List<Athlete> athletes;

  const AsymmetryTestScreen({super.key, required this.athletes});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final session = ref.watch(asymmetrySessionProvider);
    final activeSession = session.activeSession;
    final activeAthlete = activeSession != null
        ? athletes.firstWhere((a) => a.id == activeSession.athleteId,
            orElse: () => athletes.first)
        : athletes.first;

    final activeLegSession = activeSession?.activeLeg == 'right'
        ? activeSession?.rightLeg
        : activeSession?.leftLeg;
    final jumps = activeLegSession?.jumps ?? [];
    final outlierFlags = activeLegSession?.outlierFlags ?? [];

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.asymmetricTest,
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
            ref.read(asymmetrySessionProvider.notifier).reset();
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
                // Athlete chip bar
                if (session.isMultiAthlete) ...[
                  _AthleteChipBar(
                    sessions: session.orderedSessions,
                    activeAthleteId: session.activeAthleteId,
                    onSelect: (id) => ref
                        .read(asymmetrySessionProvider.notifier)
                        .setActiveAthlete(id),
                  ),
                  const SizedBox(height: 16),
                ],

                // Leg toggle
                if (activeSession != null) ...[
                  _LegToggle(
                    activeLeg: activeSession.activeLeg,
                    onChanged: (leg) => ref
                        .read(asymmetrySessionProvider.notifier)
                        .setActiveLeg(activeSession.athleteId, leg),
                  ),
                  const SizedBox(height: 16),
                ],

                // Instructions
                if (jumps.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.info_outline,
                            size: 32, color: AppColors.brand),
                        const SizedBox(height: 12),
                        Text(
                          l.asymmetryTestInstructions,
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
                for (int i = 0; i < jumps.length; i++) ...[
                  if (i > 0) const SizedBox(height: 12),
                  _JumpCard(
                    index: i,
                    jump: jumps[i],
                    isOutlier: outlierFlags.length > i && outlierFlags[i],
                    onRemove: () =>
                        ref.read(asymmetrySessionProvider.notifier).removeJump(i),
                  ),
                ],

                const SizedBox(height: 16),

                // Record jump button
                if (jumps.length < 3 && activeSession?.saved != true)
                  OutlinedButton.icon(
                    onPressed: () => _recordJump(context, ref,
                        activeSession?.activeLeg ?? 'left', jumps.length + 1),
                    icon: const Icon(Icons.videocam),
                    label: Text(l.recordLegJumpNumber(
                      activeSession?.activeLeg == 'right'
                          ? l.rightLeg
                          : l.leftLeg,
                      jumps.length + 1,
                    )),
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

                // Asymmetry summary
                if (activeSession?.asymmetryPct != null) ...[
                  const SizedBox(height: 24),
                  _AsymmetrySummary(
                    leftHeightCm:
                        activeSession!.leftLeg.averageHeightCm ?? 0,
                    rightHeightCm:
                        activeSession.rightLeg.averageHeightCm ?? 0,
                    asymmetryPct: activeSession.asymmetryPct!,
                    strongerLeg: activeSession.strongerLeg ?? 'right',
                  ),
                ],
              ],
            ),
          ),

          // Footer
          if (session.anySaveable || (activeSession?.canSave == true))
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
              onSaveAll:
                  session.isMultiAthlete ? () => _saveAll(context, ref, session) : null,
            ),
        ],
      ),
    );
  }

  Future<void> _recordJump(
    BuildContext context,
    WidgetRef ref,
    String leg,
    int jumpNumber,
  ) async {
    final result = await Navigator.of(context).push<JumpResult>(
      MaterialPageRoute(builder: (_) => const CmjVideoTrimScreen()),
    );
    if (result != null) {
      ref.read(asymmetrySessionProvider.notifier).addJump(result);
    }
  }

  Future<void> _saveAthleteSession(
    BuildContext context,
    WidgetRef ref,
    AsymmetryAthleteSession athleteSession,
    Athlete athlete, {
    required bool popOnDone,
  }) async {
    final l = AppLocalizations.of(context)!;

    final leftCount = athleteSession.leftLeg.jumps.length;
    final rightCount = athleteSession.rightLeg.jumps.length;
    if (leftCount < 1 || rightCount < 1) return;

    // Warn if either leg has fewer than 3 jumps
    if (leftCount < 3 || rightCount < 3) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.card,
          title: const Text(
            'Incomplete Test',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'You have $leftCount left-leg and $rightCount right-leg jump(s). '
            'It is recommended to record 3 per leg for accuracy. Save anyway?',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(l.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: FilledButton.styleFrom(backgroundColor: AppColors.brand),
              child: const Text('Save Anyway'),
            ),
          ],
        ),
      );
      if (proceed != true) return;
    }

    final service = ref.read(isarServiceProvider);
    final now = DateTime.now();
    final sessionId = now.millisecondsSinceEpoch;

    JumpTest buildTest(String leg, double heightCm, double deltaHCm,
        double flightTimeMs, double fps) {
      return JumpTest()
        ..athleteId = athlete.id
        ..testType = 'asymmetry'
        ..timestamp = now
        ..takeoffFrame = 0
        ..landingFrame = 0
        ..fps = fps
        ..flightTimeMs = flightTimeMs
        ..heightCm = heightCm
        ..deltaHCm = deltaHCm
        ..isOutlier = false
        ..leg = leg
        ..asymmetrySessionId = sessionId;
    }

    final leftLeg = athleteSession.leftLeg;
    final rightLeg = athleteSession.rightLeg;

    final validLeft = [
      for (int i = 0; i < leftLeg.jumps.length; i++)
        if (leftLeg.outlierFlags.length <= i || !leftLeg.outlierFlags[i])
          leftLeg.jumps[i],
    ];
    final validRight = [
      for (int i = 0; i < rightLeg.jumps.length; i++)
        if (rightLeg.outlierFlags.length <= i || !rightLeg.outlierFlags[i])
          rightLeg.jumps[i],
    ];

    final avgLeftFlight = validLeft.isEmpty
        ? 0.0
        : validLeft.map((j) => j.flightTimeMs).reduce((a, b) => a + b) /
            validLeft.length;
    final avgRightFlight = validRight.isEmpty
        ? 0.0
        : validRight.map((j) => j.flightTimeMs).reduce((a, b) => a + b) /
            validRight.length;

    final leftTest = buildTest(
      'left',
      leftLeg.averageHeightCm!,
      leftLeg.propagatedErrorCm ?? 0,
      avgLeftFlight,
      leftLeg.jumps.first.fps,
    );
    final rightTest = buildTest(
      'right',
      rightLeg.averageHeightCm!,
      rightLeg.propagatedErrorCm ?? 0,
      avgRightFlight,
      rightLeg.jumps.first.fps,
    );

    await service.saveJumpTests([leftTest, rightTest]);
    await service.updateAthleteAsymmetry(
      athlete.id,
      athleteSession.asymmetryPct!,
      athleteSession.strongerLeg!,
    );

    ref.read(asymmetrySessionProvider.notifier).markSaved(athlete.id);

    final globalActive = ref.read(activeAthleteProvider);
    if (globalActive?.id == athlete.id) {
      final updated = await service.db.athletes.get(athlete.id);
      if (updated != null) {
        ref.read(activeAthleteProvider.notifier).state = updated;
      }
    }

    if (popOnDone && context.mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _saveAll(
    BuildContext context,
    WidgetRef ref,
    AsymmetrySessionState session,
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
        SnackBar(content: Text(l.allAsymmetryTestsSaved)),
      );
      ref.read(asymmetrySessionProvider.notifier).reset();
      Navigator.of(context).pop();
    }
  }
}

// ── Leg Toggle ──

class _LegToggle extends StatelessWidget {
  final String activeLeg;
  final void Function(String) onChanged;

  const _LegToggle({required this.activeLeg, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return SegmentedButton<String>(
      segments: [
        ButtonSegment(
          value: 'left',
          label: Text(l.leftLeg),
          icon: const Icon(Icons.arrow_back),
        ),
        ButtonSegment(
          value: 'right',
          label: Text(l.rightLeg),
          icon: const Icon(Icons.arrow_forward),
        ),
      ],
      selected: {activeLeg},
      onSelectionChanged: (s) => onChanged(s.first),
      style: SegmentedButton.styleFrom(
        selectedBackgroundColor: AppColors.brand.withAlpha(30),
        selectedForegroundColor: AppColors.brand,
        foregroundColor: AppColors.textSecondary,
      ),
    );
  }
}

// ── Athlete Chip Bar ──

class _AthleteChipBar extends StatelessWidget {
  final List<AsymmetryAthleteSession> sessions;
  final int? activeAthleteId;
  final void Function(int) onSelect;

  const _AthleteChipBar({
    required this.sessions,
    required this.activeAthleteId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: sessions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final s = sessions[index];
          final isActive = s.athleteId == activeAthleteId;

          if (s.saved) {
            return Chip(
              avatar:
                  const Icon(Icons.check_circle, size: 16, color: Colors.green),
              label: Text(
                s.athleteName,
                style: const TextStyle(
                    color: Colors.green,
                    fontSize: 13,
                    fontWeight: FontWeight.w500),
              ),
              backgroundColor: Colors.green.withAlpha(20),
              side: BorderSide(color: Colors.green.withAlpha(80)),
              padding: const EdgeInsets.symmetric(horizontal: 4),
            );
          }

          final label = l.asymmetryAthleteProgress(
            s.athleteName,
            s.leftLeg.validJumpCount,
            s.rightLeg.validJumpCount,
          );

          return FilterChip(
            label: Text(
              label,
              style: TextStyle(
                color: isActive ? AppColors.brand : AppColors.textSecondary,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
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

// ── Jump Card ──

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
          color: isOutlier
              ? Colors.amber.withAlpha(100)
              : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.amber.withAlpha(30),
                        borderRadius: BorderRadius.circular(4),
                        border:
                            Border.all(color: Colors.amber.withAlpha(80)),
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
          Text(
            l.flightTimeInfo(
              jump.flightTimeMs.toStringAsFixed(1),
              jump.fps.toStringAsFixed(0),
            ),
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

// ── Asymmetry Summary Card ──

class _AsymmetrySummary extends StatelessWidget {
  final double leftHeightCm;
  final double rightHeightCm;
  final double asymmetryPct;
  final String strongerLeg;

  const _AsymmetrySummary({
    required this.leftHeightCm,
    required this.rightHeightCm,
    required this.asymmetryPct,
    required this.strongerLeg,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final color = _asymmetryColor(asymmetryPct);
    final label = _asymmetryLabel(l, asymmetryPct);
    final absStr = '${asymmetryPct.abs().round()}%';
    final signedStr = '${asymmetryPct >= 0 ? '+' : ''}${asymmetryPct.round()}%';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(80)),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(40),
            blurRadius: 16,
            spreadRadius: -4,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'ASYMMETRY RESULT',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),

          // Left / Right comparison row
          Row(
            children: [
              Expanded(
                child: _LegMetric(
                  label: l.leftAvg,
                  valueCm: leftHeightCm,
                  isStronger: strongerLeg == 'left',
                ),
              ),
              Container(
                width: 1,
                height: 48,
                color: AppColors.borderLight,
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),
              Expanded(
                child: _LegMetric(
                  label: l.rightAvg,
                  valueCm: rightHeightCm,
                  isStronger: strongerLeg == 'right',
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(color: AppColors.borderLight),
          const SizedBox(height: 12),

          // Asymmetry value
          Text(
            absStr,
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w700,
              color: color,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withAlpha(80)),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${l.strongerLeg}: ${strongerLeg == 'right' ? l.rightStronger : l.leftStronger}  ($signedStr)',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l.asymmetryPositiveNote,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegMetric extends StatelessWidget {
  final String label;
  final double valueCm;
  final bool isStronger;

  const _LegMetric({
    required this.label,
    required this.valueCm,
    required this.isStronger,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textTertiary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              valueCm.toStringAsFixed(1),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: isStronger ? AppColors.brand : AppColors.textSecondary,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(width: 2),
            Text(
              'cm',
              style: TextStyle(
                fontSize: 12,
                color: isStronger
                    ? AppColors.brand
                    : AppColors.textTertiary,
              ),
            ),
          ],
        ),
        if (isStronger)
          const Icon(Icons.arrow_upward, size: 14, color: AppColors.brand),
      ],
    );
  }
}

// ── Save Footer ──

class _SaveFooter extends StatelessWidget {
  final AsymmetrySessionState session;
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
    final activeCanSave = session.activeSession?.canSave == true &&
        session.activeSession?.saved != true;

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
                          l.saveAthleteAsymmetry(activeAthlete.name)),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.brand,
                        foregroundColor: Colors.black,
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600),
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
                        padding:
                            const EdgeInsets.symmetric(vertical: 12),
                        textStyle: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
              ],
            )
          : SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: activeCanSave ? onSaveActive : null,
                icon: const Icon(Icons.save),
                label: Text(l.saveAthleteAsymmetry(activeAthlete.name)),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.brand,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
    );
  }
}
