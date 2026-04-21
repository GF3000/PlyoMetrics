import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/athlete.dart';
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

    final flags = _computeOutlierFlags(jumps);
    final valid = [
      for (int i = 0; i < jumps.length; i++)
        if (!flags[i]) jumps[i],
    ];

    AsymmetryLegSession updatedLeg;
    if (valid.isEmpty) {
      updatedLeg = AsymmetryLegSession(
        jumps: jumps,
        outlierFlags: flags,
      );
    } else {
      final avg =
          valid.map((j) => j.heightCm).reduce((a, b) => a + b) / valid.length;
      final err =
          sqrt(
            valid
                .map((j) => j.deltaHCm * j.deltaHCm)
                .reduce((a, b) => a + b),
          ) /
          valid.length;
      updatedLeg = AsymmetryLegSession(
        jumps: jumps,
        outlierFlags: flags,
        averageHeightCm: avg,
        propagatedErrorCm: err,
      );
    }

    final newLeft = leg == 'left' ? updatedLeg : current.leftLeg;
    final newRight = leg == 'right' ? updatedLeg : current.rightLeg;

    double? asymmetry;
    String? stronger;
    final leftAvg = newLeft.averageHeightCm;
    final rightAvg = newRight.averageHeightCm;
    if (leftAvg != null && rightAvg != null) {
      final maxVal = max(leftAvg, rightAvg);
      asymmetry = (rightAvg - leftAvg) / maxVal * 100;
      stronger = rightAvg >= leftAvg ? 'right' : 'left';
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

  List<bool> _computeOutlierFlags(List<JumpResult> jumps) {
    final flags = List.filled(jumps.length, false);
    if (jumps.length >= 2) {
      for (int i = 0; i < jumps.length; i++) {
        final others = <double>[
          for (int j = 0; j < jumps.length; j++)
            if (j != i) jumps[j].heightCm,
        ];
        final meanOthers = others.reduce((a, b) => a + b) / others.length;
        final diff = (jumps[i].heightCm - meanOthers).abs();
        final threshold = max(
          0.10 * jumps[i].heightCm,
          2.0 * jumps[i].deltaHCm,
        );
        flags[i] = diff > threshold;
      }
    }
    return flags;
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
