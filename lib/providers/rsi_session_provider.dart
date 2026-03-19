import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme.dart';

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

// ── Session state ──

class RsiSessionState {
  final double dropHeightCm;
  final RsiJumpResult? result;

  const RsiSessionState({
    this.dropHeightCm = 30.0,
    this.result,
  });

  RsiSessionState copyWith({
    double? dropHeightCm,
    RsiJumpResult? result,
    bool clearResult = false,
  }) {
    return RsiSessionState(
      dropHeightCm: dropHeightCm ?? this.dropHeightCm,
      result: clearResult ? null : (result ?? this.result),
    );
  }
}

// ── Session notifier ──

class RsiSessionNotifier extends Notifier<RsiSessionState> {
  @override
  RsiSessionState build() => const RsiSessionState();

  void setDropHeight(double cm) {
    state = state.copyWith(dropHeightCm: cm);
  }

  void setResult(RsiJumpResult result) {
    state = state.copyWith(result: result);
  }

  void reset() => state = const RsiSessionState();
}

final rsiSessionProvider =
    NotifierProvider<RsiSessionNotifier, RsiSessionState>(
  RsiSessionNotifier.new,
);
