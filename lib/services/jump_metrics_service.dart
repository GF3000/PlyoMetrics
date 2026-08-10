import 'dart:math';

const double gravityMetersPerSecondSquared = 9.81;

class CmjMetrics {
  final double flightTimeMs;
  final double heightMeters;
  final double heightCm;
  final double deltaHeightCm;

  const CmjMetrics({
    required this.flightTimeMs,
    required this.heightMeters,
    required this.heightCm,
    required this.deltaHeightCm,
  });
}

class RsiMetrics {
  final double contactTimeMs;
  final double flightTimeMs;
  final double heightMeters;
  final double heightCm;
  final double rsiScore;
  final double deltaRsi;

  const RsiMetrics({
    required this.contactTimeMs,
    required this.flightTimeMs,
    required this.heightMeters,
    required this.heightCm,
    required this.rsiScore,
    required this.deltaRsi,
  });
}

class JumpSample {
  final double heightCm;
  final double deltaHeightCm;

  const JumpSample({required this.heightCm, required this.deltaHeightCm});
}

class JumpSummary {
  final List<bool> outlierFlags;
  final double? averageHeightCm;
  final double? propagatedErrorCm;

  const JumpSummary({
    required this.outlierFlags,
    required this.averageHeightCm,
    required this.propagatedErrorCm,
  });

  int get validCount => outlierFlags.where((isOutlier) => !isOutlier).length;
}

class AsymmetryMetrics {
  final double percent;
  final String strongerLeg;

  const AsymmetryMetrics({required this.percent, required this.strongerLeg});
}

class JumpMetricsService {
  const JumpMetricsService._();

  static CmjMetrics cmjFromFrames({
    required int takeoffFrame,
    required int landingFrame,
    required double fps,
  }) {
    final flightTimeSec = flightTimeSeconds(
      takeoffFrame: takeoffFrame,
      landingFrame: landingFrame,
      fps: fps,
    );
    final heightMeters = jumpHeightMeters(flightTimeSec);
    return CmjMetrics(
      flightTimeMs: flightTimeSec * 1000,
      heightMeters: heightMeters,
      heightCm: heightMeters * 100,
      deltaHeightCm: deltaHeightCm(heightMeters: heightMeters, fps: fps),
    );
  }

  static RsiMetrics rsiFromFrames({
    required int landing1Frame,
    required int takeoffFrame,
    required int landing2Frame,
    required double fps,
  }) {
    final contactTimeSec = contactTimeSeconds(
      landing1Frame: landing1Frame,
      takeoffFrame: takeoffFrame,
      fps: fps,
    );
    final flightTimeSec = flightTimeSeconds(
      takeoffFrame: takeoffFrame,
      landingFrame: landing2Frame,
      fps: fps,
    );
    final heightMeters = jumpHeightMeters(flightTimeSec);
    return RsiMetrics(
      contactTimeMs: contactTimeSec * 1000,
      flightTimeMs: flightTimeSec * 1000,
      heightMeters: heightMeters,
      heightCm: heightMeters * 100,
      rsiScore: heightMeters / contactTimeSec,
      deltaRsi: deltaRsi(
        contactTimeSec: contactTimeSec,
        flightTimeSec: flightTimeSec,
        fps: fps,
      ),
    );
  }

  static double flightTimeSeconds({
    required int takeoffFrame,
    required int landingFrame,
    required double fps,
  }) {
    _validateFps(fps);
    if (landingFrame <= takeoffFrame) {
      throw ArgumentError.value(
        landingFrame,
        'landingFrame',
        'Must be greater than takeoffFrame.',
      );
    }
    return (landingFrame - takeoffFrame) / fps;
  }

  static double contactTimeSeconds({
    required int landing1Frame,
    required int takeoffFrame,
    required double fps,
  }) {
    _validateFps(fps);
    if (takeoffFrame <= landing1Frame) {
      throw ArgumentError.value(
        takeoffFrame,
        'takeoffFrame',
        'Must be greater than landing1Frame.',
      );
    }
    return (takeoffFrame - landing1Frame) / fps;
  }

  static double jumpHeightMeters(double flightTimeSec) {
    if (flightTimeSec <= 0) {
      throw ArgumentError.value(
        flightTimeSec,
        'flightTimeSec',
        'Must be positive.',
      );
    }
    return gravityMetersPerSecondSquared * flightTimeSec * flightTimeSec / 8;
  }

  static double deltaHeightCm({
    required double heightMeters,
    required double fps,
  }) {
    _validateFps(fps);
    if (heightMeters < 0) {
      throw ArgumentError.value(
        heightMeters,
        'heightMeters',
        'Must not be negative.',
      );
    }
    return sqrt((gravityMetersPerSecondSquared * heightMeters) / 2) *
        (1 / fps) *
        100;
  }

  static double deltaRsi({
    required double contactTimeSec,
    required double flightTimeSec,
    required double fps,
  }) {
    _validateFps(fps);
    final frameDuration = 1 / fps;
    final minContact = contactTimeSec + frameDuration;
    final maxContact = contactTimeSec - frameDuration;
    final minFlight = flightTimeSec - frameDuration;
    final maxFlight = flightTimeSec + frameDuration;
    if (maxContact <= 0 || minFlight <= 0) {
      return 0;
    }

    final minHeight = jumpHeightMeters(minFlight);
    final maxHeight = jumpHeightMeters(maxFlight);
    final minRsi = minHeight / minContact;
    final maxRsi = maxHeight / maxContact;
    return (maxRsi - minRsi) / 2;
  }

  static double fatigueLossPercent({
    required double baselineHeightCm,
    required double currentHeightCm,
  }) {
    if (baselineHeightCm <= 0) {
      throw ArgumentError.value(
        baselineHeightCm,
        'baselineHeightCm',
        'Must be positive.',
      );
    }
    return ((baselineHeightCm - currentHeightCm) / baselineHeightCm) * 100;
  }

  static JumpSummary summarizeJumps(List<JumpSample> jumps) {
    final flags = outlierFlags(jumps);
    final valid = [
      for (var i = 0; i < jumps.length; i++)
        if (!flags[i]) jumps[i],
    ];
    if (valid.isEmpty) {
      return JumpSummary(
        outlierFlags: flags,
        averageHeightCm: null,
        propagatedErrorCm: null,
      );
    }

    final averageHeight =
        valid.map((jump) => jump.heightCm).reduce((a, b) => a + b) /
            valid.length;
    final propagatedError =
        rootMeanSquare(valid.map((jump) => jump.deltaHeightCm));
    return JumpSummary(
      outlierFlags: flags,
      averageHeightCm: averageHeight,
      propagatedErrorCm: propagatedError,
    );
  }

  static List<bool> outlierFlags(List<JumpSample> jumps) {
    final flags = List.filled(jumps.length, false);
    if (jumps.length < 2) return flags;

    for (var i = 0; i < jumps.length; i++) {
      final others = <double>[
        for (var j = 0; j < jumps.length; j++)
          if (j != i) jumps[j].heightCm,
      ];
      final meanOthers = others.reduce((a, b) => a + b) / others.length;
      final diff = (jumps[i].heightCm - meanOthers).abs();
      final threshold = max(
        0.10 * jumps[i].heightCm,
        2.0 * jumps[i].deltaHeightCm,
      );
      flags[i] = diff > threshold;
    }
    return flags;
  }

  static double rootMeanSquare(Iterable<double> values) {
    final list = values.toList();
    if (list.isEmpty) {
      throw ArgumentError.value(values, 'values', 'Must not be empty.');
    }
    return sqrt(list.map((value) => value * value).reduce((a, b) => a + b)) /
        list.length;
  }

  static AsymmetryMetrics asymmetry({
    required double leftHeightCm,
    required double rightHeightCm,
  }) {
    if (leftHeightCm <= 0 || rightHeightCm <= 0) {
      throw ArgumentError('Leg jump heights must be positive.');
    }
    final maxHeight = max(leftHeightCm, rightHeightCm);
    return AsymmetryMetrics(
      percent: (rightHeightCm - leftHeightCm) / maxHeight * 100,
      strongerLeg: rightHeightCm >= leftHeightCm ? 'right' : 'left',
    );
  }

  static void _validateFps(double fps) {
    if (fps <= 0) {
      throw ArgumentError.value(fps, 'fps', 'Must be positive.');
    }
  }
}
