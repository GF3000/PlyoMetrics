import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    const g = 9.81;
    return sqrt((g * heightMeters) / 2) * (1 / fps) * 100;
  }
}

// ── Session state ──

class CmjSessionState {
  final List<JumpResult> jumps;
  final List<bool> outlierFlags;
  final double? averageHeightCm;
  final double? propagatedErrorCm;
  final bool canSave;

  const CmjSessionState({
    this.jumps = const [],
    this.outlierFlags = const [],
    this.averageHeightCm,
    this.propagatedErrorCm,
    this.canSave = false,
  });

  CmjSessionState copyWith({
    List<JumpResult>? jumps,
    List<bool>? outlierFlags,
    double? averageHeightCm,
    double? propagatedErrorCm,
    bool? canSave,
  }) {
    return CmjSessionState(
      jumps: jumps ?? this.jumps,
      outlierFlags: outlierFlags ?? this.outlierFlags,
      averageHeightCm: averageHeightCm ?? this.averageHeightCm,
      propagatedErrorCm: propagatedErrorCm ?? this.propagatedErrorCm,
      canSave: canSave ?? this.canSave,
    );
  }
}

// ── Session notifier ──

class CmjSessionNotifier extends Notifier<CmjSessionState> {
  @override
  CmjSessionState build() => const CmjSessionState();

  void addJump(JumpResult result) {
    final newJumps = [...state.jumps, result];
    _recalculate(newJumps);
  }

  void removeJump(int index) {
    final newJumps = [...state.jumps]..removeAt(index);
    _recalculate(newJumps);
  }

  void reset() => state = const CmjSessionState();

  void _recalculate(List<JumpResult> jumps) {
    if (jumps.length < 2) {
      state = CmjSessionState(
        jumps: jumps,
        outlierFlags: List.filled(jumps.length, false),
      );
      return;
    }

    // Outlier detection: a jump is an outlier if its difference from the
    // mean of the OTHER jumps exceeds max(10% of its height, 2 * deltaH).
    final flags = List.filled(jumps.length, false);
    for (int i = 0; i < jumps.length; i++) {
      final others = <double>[
        for (int j = 0; j < jumps.length; j++)
          if (j != i) jumps[j].heightCm,
      ];
      final meanOthers = others.reduce((a, b) => a + b) / others.length;
      final diff = (jumps[i].heightCm - meanOthers).abs();
      final threshold = max(0.10 * jumps[i].heightCm, 2.0 * jumps[i].deltaHCm);
      flags[i] = diff > threshold;
    }

    // Average excluding outliers
    final valid = <JumpResult>[
      for (int i = 0; i < jumps.length; i++)
        if (!flags[i]) jumps[i],
    ];

    if (valid.isEmpty) {
      state = CmjSessionState(jumps: jumps, outlierFlags: flags);
      return;
    }

    final avgHeight =
        valid.map((j) => j.heightCm).reduce((a, b) => a + b) / valid.length;

    // Propagated error: sqrt(sum(deltaH^2)) / N
    final propagatedError =
        sqrt(valid.map((j) => j.deltaHCm * j.deltaHCm).reduce((a, b) => a + b)) /
            valid.length;

    state = CmjSessionState(
      jumps: jumps,
      outlierFlags: flags,
      averageHeightCm: avgHeight,
      propagatedErrorCm: propagatedError,
      canSave: valid.length >= 2,
    );
  }
}

final cmjSessionProvider =
    NotifierProvider<CmjSessionNotifier, CmjSessionState>(
  CmjSessionNotifier.new,
);
