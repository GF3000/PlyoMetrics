import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/athlete.dart';
import '../services/jump_metrics_service.dart';
import 'cmj_session_provider.dart';

// ── Per-leg session ──

class AsymmetryLegSession {
  final List<JumpResult> jumps;
  final List<bool> outlierFlags;
  final double? averageHeightCm;
  final double? propagatedErrorCm;

  const AsymmetryLegSession({
    this.jumps = const [],
    this.outlierFlags = const [],
    this.averageHeightCm,
    this.propagatedErrorCm,
  });

  int get validJumpCount =>
      outlierFlags.isEmpty ? 0 : outlierFlags.where((f) => !f).length;

  AsymmetryLegSession copyWith({
    List<JumpResult>? jumps,
    List<bool>? outlierFlags,
    double? averageHeightCm,
    double? propagatedErrorCm,
  }) {
    return AsymmetryLegSession(
      jumps: jumps ?? this.jumps,
      outlierFlags: outlierFlags ?? this.outlierFlags,
      averageHeightCm: averageHeightCm ?? this.averageHeightCm,
      propagatedErrorCm: propagatedErrorCm ?? this.propagatedErrorCm,
    );
  }
}

// ── Per-athlete session ──

class AsymmetryAthleteSession {
  final int athleteId;
  final String athleteName;
  final AsymmetryLegSession leftLeg;
  final AsymmetryLegSession rightLeg;
  final String activeLeg; // 'left' | 'right'
  final double? asymmetryPct; // signed: positive = right stronger
  final String? strongerLeg; // 'left' | 'right'
  final bool canSave;
  final bool saved;

  const AsymmetryAthleteSession({
    required this.athleteId,
    required this.athleteName,
    this.leftLeg = const AsymmetryLegSession(),
    this.rightLeg = const AsymmetryLegSession(),
    this.activeLeg = 'left',
    this.asymmetryPct,
    this.strongerLeg,
    this.canSave = false,
    this.saved = false,
  });

  AsymmetryLegSession get activeSession =>
      activeLeg == 'left' ? leftLeg : rightLeg;

  AsymmetryAthleteSession copyWith({
    AsymmetryLegSession? leftLeg,
    AsymmetryLegSession? rightLeg,
    String? activeLeg,
    double? asymmetryPct,
    String? strongerLeg,
    bool? canSave,
    bool? saved,
    bool clearAsymmetry = false,
    bool clearStrongerLeg = false,
  }) {
    return AsymmetryAthleteSession(
      athleteId: athleteId,
      athleteName: athleteName,
      leftLeg: leftLeg ?? this.leftLeg,
      rightLeg: rightLeg ?? this.rightLeg,
      activeLeg: activeLeg ?? this.activeLeg,
      asymmetryPct: clearAsymmetry ? null : (asymmetryPct ?? this.asymmetryPct),
      strongerLeg:
          clearStrongerLeg ? null : (strongerLeg ?? this.strongerLeg),
      canSave: canSave ?? this.canSave,
      saved: saved ?? this.saved,
    );
  }
}

// ── Session state ──

class AsymmetrySessionState {
  final Map<int, AsymmetryAthleteSession> athleteSessions;
  final List<AsymmetryAthleteSession> orderedSessions;
  final int? activeAthleteId;

  const AsymmetrySessionState({
    this.athleteSessions = const {},
    this.orderedSessions = const [],
    this.activeAthleteId,
  });

  AsymmetryAthleteSession? get activeSession =>
      activeAthleteId != null ? athleteSessions[activeAthleteId] : null;

  bool get isMultiAthlete => orderedSessions.length > 1;
  bool get allSaved =>
      orderedSessions.isNotEmpty && orderedSessions.every((s) => s.saved);
  bool get anySaveable => orderedSessions.any((s) => s.canSave && !s.saved);

  AsymmetrySessionState copyWith({
    Map<int, AsymmetryAthleteSession>? athleteSessions,
    List<AsymmetryAthleteSession>? orderedSessions,
    int? activeAthleteId,
  }) {
    return AsymmetrySessionState(
      athleteSessions: athleteSessions ?? this.athleteSessions,
      orderedSessions: orderedSessions ?? this.orderedSessions,
      activeAthleteId: activeAthleteId ?? this.activeAthleteId,
    );
  }
}

// ── Session notifier ──

class AsymmetrySessionNotifier extends Notifier<AsymmetrySessionState> {
  @override
  AsymmetrySessionState build() => const AsymmetrySessionState();

  void initWithAthletes(List<Athlete> athletes, {int? defaultAthleteId}) {
    assert(athletes.isNotEmpty);
    final sessions = <int, AsymmetryAthleteSession>{
      for (final a in athletes)
        a.id: AsymmetryAthleteSession(
          athleteId: a.id,
          athleteName: a.name,
        ),
    };
    final activeId =
        defaultAthleteId != null && sessions.containsKey(defaultAthleteId)
        ? defaultAthleteId
        : athletes.first.id;
    state = AsymmetrySessionState(
      athleteSessions: sessions,
      orderedSessions: [for (final a in athletes) sessions[a.id]!],
      activeAthleteId: activeId,
    );
  }

  void setActiveAthlete(int athleteId) {
    assert(state.athleteSessions.containsKey(athleteId));
    state = state.copyWith(activeAthleteId: athleteId);
  }

  void setActiveLeg(int athleteId, String leg) {
    assert(leg == 'left' || leg == 'right');
    final session = state.athleteSessions[athleteId]!;
    _replaceSession(athleteId, session.copyWith(activeLeg: leg));
  }

  void addJump(JumpResult result) {
    final id = state.activeAthleteId;
    if (id == null) return;
    final session = state.athleteSessions[id]!;
    final leg = session.activeLeg;
    final currentJumps = leg == 'left'
        ? session.leftLeg.jumps
        : session.rightLeg.jumps;
    _recalculateForAthleteLeg(id, leg, [...currentJumps, result]);
  }

  void removeJump(int index) {
    final id = state.activeAthleteId;
    if (id == null) return;
    final session = state.athleteSessions[id]!;
    final leg = session.activeLeg;
    final currentJumps = leg == 'left'
        ? session.leftLeg.jumps
        : session.rightLeg.jumps;
    final newJumps = [...currentJumps]..removeAt(index);
    _recalculateForAthleteLeg(id, leg, newJumps);
  }

  void markSaved(int athleteId) {
    final updated = state.athleteSessions[athleteId]!.copyWith(saved: true);
    _replaceSession(athleteId, updated);
  }

  void reset() => state = const AsymmetrySessionState();

  void _recalculateForAthleteLeg(
    int athleteId,
    String leg,
    List<JumpResult> jumps,
  ) {
    final current = state.athleteSessions[athleteId]!;

    final summary = JumpMetricsService.summarizeJumps([
      for (final jump in jumps)
        JumpSample(heightCm: jump.heightCm, deltaHeightCm: jump.deltaHCm),
    ]);

    AsymmetryLegSession updatedLeg;
    if (summary.averageHeightCm == null || summary.propagatedErrorCm == null) {
      updatedLeg = AsymmetryLegSession(
        jumps: jumps,
        outlierFlags: summary.outlierFlags,
      );
    } else {
      updatedLeg = AsymmetryLegSession(
        jumps: jumps,
        outlierFlags: summary.outlierFlags,
        averageHeightCm: summary.averageHeightCm,
        propagatedErrorCm: summary.propagatedErrorCm,
      );
    }

    final newLeft = leg == 'left' ? updatedLeg : current.leftLeg;
    final newRight = leg == 'right' ? updatedLeg : current.rightLeg;

    double? asymmetry;
    String? stronger;
    final leftAvg = newLeft.averageHeightCm;
    final rightAvg = newRight.averageHeightCm;
    if (leftAvg != null && rightAvg != null) {
      final metrics = JumpMetricsService.asymmetry(
        leftHeightCm: leftAvg,
        rightHeightCm: rightAvg,
      );
      asymmetry = metrics.percent;
      stronger = metrics.strongerLeg;
    }

    final canSave = leftAvg != null && rightAvg != null;

    _replaceSession(
      athleteId,
      AsymmetryAthleteSession(
        athleteId: athleteId,
        athleteName: current.athleteName,
        leftLeg: newLeft,
        rightLeg: newRight,
        activeLeg: current.activeLeg,
        asymmetryPct: asymmetry,
        strongerLeg: stronger,
        canSave: canSave,
        saved: current.saved,
      ),
    );
  }

  void _replaceSession(int athleteId, AsymmetryAthleteSession updated) {
    final newMap =
        Map<int, AsymmetryAthleteSession>.from(state.athleteSessions)
          ..[athleteId] = updated;
    final newOrdered = [
      for (final s in state.orderedSessions)
        if (s.athleteId == athleteId) updated else s,
    ];
    state = state.copyWith(
      athleteSessions: newMap,
      orderedSessions: newOrdered,
    );
  }
}

final asymmetrySessionProvider =
    NotifierProvider<AsymmetrySessionNotifier, AsymmetrySessionState>(
      AsymmetrySessionNotifier.new,
    );
