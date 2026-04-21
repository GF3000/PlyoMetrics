import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme.dart';
import '../models/athlete.dart';
import '../models/jump_test.dart';
import '../providers/management_providers.dart';
import '../providers/rsi_session_provider.dart';
import 'rsi_video_trim_screen.dart';

class RsiTestScreen extends ConsumerWidget {
  final List<Athlete> athletes;

  const RsiTestScreen({super.key, required this.athletes});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final session = ref.watch(rsiSessionProvider);
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
              l.rsiDropJump,
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
            ref.read(rsiSessionProvider.notifier).reset();
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
                        ref.read(rsiSessionProvider.notifier).setActiveAthlete(id),
                  ),
                  const SizedBox(height: 16),
                ],

                // Drop height selector
                _DropHeightSelector(
                  current: session.dropHeightCm,
                  onChanged: (h) =>
                      ref.read(rsiSessionProvider.notifier).setDropHeight(h),
                ),
                const SizedBox(height: 20),

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
                          l.rsiTestInstructions,
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
                  if (i > 0 || session.jumps.isEmpty)
                    const SizedBox(height: 12),
                  _RsiJumpCard(
                    index: i,
                    jump: session.jumps[i],
                    onRemove: () =>
                        ref.read(rsiSessionProvider.notifier).removeJump(i),
                  ),
                ],

                const SizedBox(height: 16),

                // Record jump button
                if (session.jumps.length < 3 && activeSession?.saved != true)
                  OutlinedButton.icon(
                    onPressed: () => _recordJump(context, ref),
                    icon: const Icon(Icons.videocam),
                    label: Text(l.recordDropJumpNumber(session.jumps.length + 1)),
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
                if (activeSession?.averageRsi != null) ...[
                  const SizedBox(height: 24),
                  _RsiSummary(
                    averageRsi: activeSession!.averageRsi!,
                    averageDeltaRsi: activeSession.averageDeltaRsi!,
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
    final result = await Navigator.of(context).push<RsiJumpResult>(
      MaterialPageRoute(builder: (_) => const RsiVideoTrimScreen()),
    );
    if (result == null) return;

    final dropHeight = ref.read(rsiSessionProvider).dropHeightCm;
    final adjusted = RsiJumpResult(
      landing1Frame: result.landing1Frame,
      takeoffFrame: result.takeoffFrame,
      landing2Frame: result.landing2Frame,
      fps: result.fps,
      contactTimeMs: result.contactTimeMs,
      flightTimeMs: result.flightTimeMs,
      heightCm: result.heightCm,
      rsiScore: result.rsiScore,
      deltaRsi: result.deltaRsi,
      dropHeightCm: dropHeight,
      videoPath: result.videoPath,
    );

    ref.read(rsiSessionProvider.notifier).addJump(adjusted);
  }

  Future<void> _saveAthleteSession(
    BuildContext context,
    WidgetRef ref,
    RsiAthleteSession athleteSession,
    Athlete athlete, {
    required bool popOnDone,
  }) async {
    final service = ref.read(isarServiceProvider);
    final jumps = athleteSession.jumps;
    final avgRsi = athleteSession.averageRsi!;
    final avgDeltaRsi = athleteSession.averageDeltaRsi!;
    final avgContactTimeMs =
        jumps.map((j) => j.contactTimeMs).reduce((a, b) => a + b) / jumps.length;
    final avgFlightTimeMs =
        jumps.map((j) => j.flightTimeMs).reduce((a, b) => a + b) / jumps.length;
    final avgHeightCm =
        jumps.map((j) => j.heightCm).reduce((a, b) => a + b) / jumps.length;
    final dropHeightCm = ref.read(rsiSessionProvider).dropHeightCm;

    final test = JumpTest()
      ..athleteId = athlete.id
      ..testType = 'rsi'
      ..timestamp = DateTime.now()
      ..landing1Frame = jumps.first.landing1Frame
      ..takeoffFrame = jumps.first.takeoffFrame
      ..landingFrame = jumps.first.landing2Frame
      ..fps = jumps.first.fps
      ..flightTimeMs = avgFlightTimeMs
      ..heightCm = avgHeightCm
      ..deltaHCm = 0.0
      ..contactTimeMs = avgContactTimeMs
      ..rsiScore = avgRsi
      ..deltaRsi = avgDeltaRsi
      ..dropHeightCm = dropHeightCm;

    await service.saveJumpTests([test]);
    await service.updateAthleteRsi(athlete.id, avgRsi);

    // Keep activeAthleteProvider in sync for the dashboard
    final globalActive = ref.read(activeAthleteProvider);
    if (globalActive?.id == athlete.id) {
      final updatedAthlete = await service.db.athletes.get(athlete.id);
      if (updatedAthlete != null) {
        ref.read(activeAthleteProvider.notifier).state = updatedAthlete;
      }
    }

    ref.read(rsiSessionProvider.notifier).markSaved(athlete.id);

    if (popOnDone && context.mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _saveAll(
    BuildContext context,
    WidgetRef ref,
    RsiSessionState session,
  ) async {
    final l = AppLocalizations.of(context)!;
    final toSave =
        session.orderedSessions.where((s) => s.canSave && !s.saved).toList();

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
        SnackBar(content: Text(l.allRsiTestsSaved)),
      );
      ref.read(rsiSessionProvider.notifier).reset();
      Navigator.of(context).pop();
    }
  }
}

// ── Athlete Chip Bar ──

class _AthleteChipBar extends StatelessWidget {
  final List<RsiAthleteSession> sessions;
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
          final label = '${s.athleteName} (${s.jumps.length}/3)';

          if (s.saved) {
            return _SavedChip(label: s.athleteName);
          }

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

// ── Drop Height Selector ──

class _DropHeightSelector extends StatelessWidget {
  final double current;
  final void Function(double) onChanged;

  const _DropHeightSelector({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    const heights = [20.0, 30.0, 40.0, 50.0];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.dropHeight,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        SegmentedButton<double>(
          segments: heights
              .map((h) => ButtonSegment(
                    value: h,
                    label: Text(l.heightCm(h.toInt())),
                  ))
              .toList(),
          selected: {current},
          onSelectionChanged: (set) => onChanged(set.first),
          style: SegmentedButton.styleFrom(
            selectedBackgroundColor: AppColors.brand,
            selectedForegroundColor: Colors.black,
            foregroundColor: AppColors.textSecondary,
            backgroundColor: AppColors.card,
            side: const BorderSide(color: AppColors.borderLight),
            textStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

// ── RSI Jump Card ──

class _RsiJumpCard extends StatelessWidget {
  final int index;
  final RsiJumpResult jump;
  final VoidCallback onRemove;

  const _RsiJumpCard({
    required this.index,
    required this.jump,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final quality = rsiQuality(jump.rsiScore);

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l.jumpNumber(index + 1),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
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
                jump.rsiScore.toStringAsFixed(2),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: AppColors.brand,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '± ${jump.deltaRsi.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                quality.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: quality.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${l.contact}: ${jump.contactTimeMs.toStringAsFixed(0)} ms  ·  '
            '${l.flight}: ${jump.flightTimeMs.toStringAsFixed(0)} ms  ·  '
            '${jump.fps.toStringAsFixed(0)} FPS',
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

// ── RSI Summary ──

class _RsiSummary extends StatelessWidget {
  final double averageRsi;
  final double averageDeltaRsi;

  const _RsiSummary({
    required this.averageRsi,
    required this.averageDeltaRsi,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final quality = rsiQuality(averageRsi);

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
            l.averageRsiScore,
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
                averageRsi.toStringAsFixed(2),
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '± ${averageDeltaRsi.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            quality.label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: quality.color,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Save Footer ──

class _SaveFooter extends StatelessWidget {
  final RsiSessionState session;
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
                      label: Text(l.saveAthleteRsi(activeAthlete.name)),
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
              label: Text(l.saveTestResult),
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
