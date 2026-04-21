import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme.dart';
import '../models/athlete.dart';

// ── In-memory result from a single RSI drop jump analysis ──

class RsiJumpResult {
  final int landing1Frame; // first ground contact after drop
  final int takeoffFrame; // leaves ground
  final int landing2Frame; // lands after flight phase
  final double fps;
  final double contactTimeMs;
  final double flightTimeMs;
  final double heightCm;
  final double rsiScore;
  final double deltaRsi;
  final double dropHeightCm;
  final String videoPath;

  const RsiJumpResult({
    required this.landing1Frame,
    required this.takeoffFrame,
    required this.landing2Frame,
    required this.fps,
    required this.contactTimeMs,
    required this.flightTimeMs,
    required this.heightCm,
    required this.rsiScore,
    required this.deltaRsi,
    required this.dropHeightCm,
    required this.videoPath,
  });

  /// Compute RSI result from raw frame data.
  factory RsiJumpResult.fromFrames({
    required int landing1Frame,
    required int takeoffFrame,
    required int landing2Frame,
    required double fps,
    required double dropHeightCm,
    required String videoPath,
  }) {
    const g = 9.81;
    final frameDuration = 1 / fps;
    final contactTimeSec = (takeoffFrame - landing1Frame) / fps;
    final flightTimeSec = (landing2Frame - takeoffFrame) / fps;
    final heightMeters = g * flightTimeSec * flightTimeSec / 8;
    final rsi = heightMeters / contactTimeSec;

    // ±1 frame error propagation
    double deltaRsi = 0.0;
    final minContact = contactTimeSec + frameDuration;
    final maxContact = contactTimeSec - frameDuration;
    final minFlight = flightTimeSec - frameDuration;
    final maxFlight = flightTimeSec + frameDuration;
    if (maxContact > 0 && minFlight > 0) {
      final minH = g * minFlight * minFlight / 8;
      final maxH = g * maxFlight * maxFlight / 8;
      final minRsi = minH / minContact;
      final maxRsi = maxH / maxContact;
      deltaRsi = (maxRsi - minRsi) / 2;
    }

    return RsiJumpResult(
      landing1Frame: landing1Frame,
      takeoffFrame: takeoffFrame,
      landing2Frame: landing2Frame,
      fps: fps,
      contactTimeMs: contactTimeSec * 1000,
      flightTimeMs: flightTimeSec * 1000,
      heightCm: heightMeters * 100,
      rsiScore: rsi,
      deltaRsi: deltaRsi,
      dropHeightCm: dropHeightCm,
      videoPath: videoPath,
    );
  }
}

// ── RSI quality thresholds ──

({String label, Color color}) rsiQuality(double rsiScore) {
  if (rsiScore < 1.50) {
    return (label: 'Needs Improvement', color: const Color(0xFFEF4444));
  }
  if (rsiScore < 2.00) {
    return (label: 'Fair', color: const Color(0xFFF97316));
  }
  if (rsiScore < 2.50) {
    return (label: 'Good', color: const Color(0xFFFACC15));
  }
  if (rsiScore < 3.00) {
    return (label: 'Excellent', color: AppColors.brand);
  }
  return (label: 'Elite', color: const Color(0xFF4ADE80));
}

// ── Per-athlete RSI session ──

class RsiAthleteSession {
  final int athleteId;
  final String athleteName;
  final List<RsiJumpResult> jumps;
  final double? averageRsi;
  final double? averageDeltaRsi;
  final bool canSave;
  final bool saved;

  const RsiAthleteSession({
    required this.athleteId,
    required this.athleteName,
    this.jumps = const [],
    this.averageRsi,
    this.averageDeltaRsi,
    this.canSave = false,
    this.saved = false,
  });
}

// ── Session state ──

class RsiSessionState {
  final double dropHeightCm;
  final Map<int, RsiAthleteSession> athleteSessions;
  final List<RsiAthleteSession> orderedSessions;
  final int? activeAthleteId;

  const RsiSessionState({
    this.dropHeightCm = 30.0,
    this.athleteSessions = const {},
    this.orderedSessions = const [],
    this.activeAthleteId,
  });

  RsiAthleteSession? get activeSession =>
      activeAthleteId != null ? athleteSessions[activeAthleteId] : null;

  List<RsiJumpResult> get jumps => activeSession?.jumps ?? const [];
  bool get isMultiAthlete => orderedSessions.length > 1;
  bool get canSave => activeSession?.canSave ?? false;
  bool get anySaveable => orderedSessions.any((s) => s.canSave && !s.saved);

  RsiSessionState copyWith({
    double? dropHeightCm,
    Map<int, RsiAthleteSession>? athleteSessions,
    List<RsiAthleteSession>? orderedSessions,
    int? activeAthleteId,
  }) {
    return RsiSessionState(
      dropHeightCm: dropHeightCm ?? this.dropHeightCm,
      athleteSessions: athleteSessions ?? this.athleteSessions,
      orderedSessions: orderedSessions ?? this.orderedSessions,
      activeAthleteId: activeAthleteId ?? this.activeAthleteId,
    );
  }
}

// ── Session notifier ──

class RsiSessionNotifier extends Notifier<RsiSessionState> {
  @override
  RsiSessionState build() => const RsiSessionState();

  void initWithAthletes(List<Athlete> athletes, {int? defaultAthleteId}) {
    assert(athletes.isNotEmpty);
    final sessions = <int, RsiAthleteSession>{
      for (final a in athletes)
        a.id: RsiAthleteSession(athleteId: a.id, athleteName: a.name),
    };
    final activeId =
        defaultAthleteId != null && sessions.containsKey(defaultAthleteId)
        ? defaultAthleteId
        : athletes.first.id;
    state = RsiSessionState(
      athleteSessions: sessions,
      orderedSessions: [for (final a in athletes) sessions[a.id]!],
      activeAthleteId: activeId,
    );
  }

  void setActiveAthlete(int athleteId) {
    assert(state.athleteSessions.containsKey(athleteId));
    state = state.copyWith(activeAthleteId: athleteId);
  }

  void setDropHeight(double cm) {
    state = state.copyWith(dropHeightCm: cm);
  }

  void addJump(RsiJumpResult result) {
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
    final current = state.athleteSessions[athleteId]!;
    _replaceSession(
      athleteId,
      RsiAthleteSession(
        athleteId: current.athleteId,
        athleteName: current.athleteName,
        jumps: current.jumps,
        averageRsi: current.averageRsi,
        averageDeltaRsi: current.averageDeltaRsi,
        canSave: current.canSave,
        saved: true,
      ),
    );
  }

  void reset() => state = const RsiSessionState();

  void _recalculateForAthlete(int athleteId, List<RsiJumpResult> jumps) {
    final current = state.athleteSessions[athleteId]!;

    if (jumps.isEmpty) {
      _replaceSession(
        athleteId,
        RsiAthleteSession(
          athleteId: athleteId,
          athleteName: current.athleteName,
          jumps: const [],
          canSave: false,
          saved: current.saved,
        ),
      );
      return;
    }

    final avgRsi =
        jumps.map((j) => j.rsiScore).reduce((a, b) => a + b) / jumps.length;
    final avgDelta =
        sqrt(
          jumps.map((j) => j.deltaRsi * j.deltaRsi).reduce((a, b) => a + b),
        ) /
        jumps.length;

    _replaceSession(
      athleteId,
      RsiAthleteSession(
        athleteId: athleteId,
        athleteName: current.athleteName,
        jumps: jumps,
        averageRsi: avgRsi,
        averageDeltaRsi: avgDelta,
        canSave: true,
        saved: current.saved,
      ),
    );
  }

  void _replaceSession(int athleteId, RsiAthleteSession updated) {
    final newMap = Map<int, RsiAthleteSession>.from(state.athleteSessions)
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

final rsiSessionProvider =
    NotifierProvider<RsiSessionNotifier, RsiSessionState>(
      RsiSessionNotifier.new,
    );
