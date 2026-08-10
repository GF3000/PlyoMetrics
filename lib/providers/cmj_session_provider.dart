import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/athlete.dart';
import '../services/jump_metrics_service.dart';

// ── In-memory result from a single jump analysis ──

class JumpResult {
  final int takeoffFrame;
  final int landingFrame;
  final double fps;
  final double flightTimeMs;
  final double heightCm;
  final double deltaHCm;
  final String videoPath;

  const JumpResult({
    required this.takeoffFrame,
    required this.landingFrame,
    required this.fps,
    required this.flightTimeMs,
    required this.heightCm,
    required this.deltaHCm,
    required this.videoPath,
  });

  /// Sensitivity error: deltaH = sqrt((g * h) / 2) * (1 / fps) * 100
  /// where h is height in meters, result in cm.
  static double computeDeltaH(double heightMeters, double fps) {
    return JumpMetricsService.deltaHeightCm(
      heightMeters: heightMeters,
      fps: fps,
    );
  }
}

// ── Per-athlete in-memory session ──

class AthleteSession {
  final int athleteId;
  final String athleteName;
  final List<JumpResult> jumps;
  final List<bool> outlierFlags;
  final double? averageHeightCm;
  final double? propagatedErrorCm;
  final bool canSave;
  final bool saved;

  const AthleteSession({
    required this.athleteId,
    required this.athleteName,
    this.jumps = const [],
    this.outlierFlags = const [],
    this.averageHeightCm,
    this.propagatedErrorCm,
    this.canSave = false,
    this.saved = false,
  });

  AthleteSession copyWith({
    List<JumpResult>? jumps,
    List<bool>? outlierFlags,
    double? averageHeightCm,
    double? propagatedErrorCm,
    bool? canSave,
    bool? saved,
  }) {
    return AthleteSession(
      athleteId: athleteId,
      athleteName: athleteName,
      jumps: jumps ?? this.jumps,
      outlierFlags: outlierFlags ?? this.outlierFlags,
      averageHeightCm: averageHeightCm ?? this.averageHeightCm,
      propagatedErrorCm: propagatedErrorCm ?? this.propagatedErrorCm,
      canSave: canSave ?? this.canSave,
      saved: saved ?? this.saved,
    );
  }

  int get validJumpCount =>
      outlierFlags.isEmpty ? 0 : outlierFlags.where((f) => !f).length;
}

// ── Session state ──

class CmjSessionState {
  final Map<int, AthleteSession> athleteSessions;
  final List<AthleteSession> orderedSessions;
  final int? activeAthleteId;

  const CmjSessionState({
    this.athleteSessions = const {},
    this.orderedSessions = const [],
    this.activeAthleteId,
  });

  AthleteSession? get activeSession =>
      activeAthleteId != null ? athleteSessions[activeAthleteId] : null;

  // Back-compat getters so existing call sites compile unchanged
  List<JumpResult> get jumps => activeSession?.jumps ?? const [];
  List<bool> get outlierFlags => activeSession?.outlierFlags ?? const [];
  double? get averageHeightCm => activeSession?.averageHeightCm;
  double? get propagatedErrorCm => activeSession?.propagatedErrorCm;
  bool get canSave => activeSession?.canSave ?? false;

  bool get isMultiAthlete => orderedSessions.length > 1;
  bool get allSaved =>
      orderedSessions.isNotEmpty && orderedSessions.every((s) => s.saved);
  bool get anySaveable => orderedSessions.any((s) => s.canSave && !s.saved);

  CmjSessionState copyWith({
    Map<int, AthleteSession>? athleteSessions,
    List<AthleteSession>? orderedSessions,
    int? activeAthleteId,
  }) {
    return CmjSessionState(
      athleteSessions: athleteSessions ?? this.athleteSessions,
      orderedSessions: orderedSessions ?? this.orderedSessions,
      activeAthleteId: activeAthleteId ?? this.activeAthleteId,
    );
  }
}

// ── Session notifier ──

class CmjSessionNotifier extends Notifier<CmjSessionState> {
  @override
  CmjSessionState build() => const CmjSessionState();

  void initWithAthletes(List<Athlete> athletes, {int? defaultAthleteId}) {
    assert(athletes.isNotEmpty);
    final sessions = <int, AthleteSession>{
      for (final a in athletes)
        a.id: AthleteSession(athleteId: a.id, athleteName: a.name),
    };
    final activeId =
        defaultAthleteId != null && sessions.containsKey(defaultAthleteId)
        ? defaultAthleteId
        : athletes.first.id;
    state = CmjSessionState(
      athleteSessions: sessions,
      orderedSessions: [for (final a in athletes) sessions[a.id]!],
      activeAthleteId: activeId,
    );
  }

  void setActiveAthlete(int athleteId) {
    assert(state.athleteSessions.containsKey(athleteId));
    state = state.copyWith(activeAthleteId: athleteId);
  }

  void addJump(JumpResult result) {
    final id = state.activeAthleteId;
    if (id == null) return;
    final session = state.athleteSessions[id]!;
    _recalculateForAthlete(id, [...session.jumps, result]);
  }

  void removeJump(int index) {
    final id = state.activeAthleteId;
    if (id == null) return;
    final session = state.athleteSessions[id]!;
    final newJumps = [...session.jumps]..removeAt(index);
    _recalculateForAthlete(id, newJumps);
  }

  void markSaved(int athleteId) {
    final updated = state.athleteSessions[athleteId]!.copyWith(saved: true);
    _replaceSession(athleteId, updated);
  }

  void reset() => state = const CmjSessionState();

  void _recalculateForAthlete(int athleteId, List<JumpResult> jumps) {
    final current = state.athleteSessions[athleteId]!;

    if (jumps.isEmpty) {
      _replaceSession(
        athleteId,
        current.copyWith(jumps: jumps, outlierFlags: [], canSave: false),
      );
      return;
    }

    final summary = JumpMetricsService.summarizeJumps([
      for (final jump in jumps)
        JumpSample(heightCm: jump.heightCm, deltaHeightCm: jump.deltaHCm),
    ]);

    if (summary.averageHeightCm == null || summary.propagatedErrorCm == null) {
      _replaceSession(
        athleteId,
        current.copyWith(
          jumps: jumps,
          outlierFlags: summary.outlierFlags,
          canSave: false,
        ),
      );
      return;
    }

    _replaceSession(
      athleteId,
      AthleteSession(
        athleteId: athleteId,
        athleteName: current.athleteName,
        jumps: jumps,
        outlierFlags: summary.outlierFlags,
        averageHeightCm: summary.averageHeightCm,
        propagatedErrorCm: summary.propagatedErrorCm,
        canSave: summary.validCount >= 2,
        saved: current.saved,
      ),
    );
  }

  void _replaceSession(int athleteId, AthleteSession updated) {
    final newMap = Map<int, AthleteSession>.from(state.athleteSessions)
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

final cmjSessionProvider =
    NotifierProvider<CmjSessionNotifier, CmjSessionState>(
      CmjSessionNotifier.new,
    );
