import 'package:flutter_test/flutter_test.dart';
import 'package:PlyoMetrics/services/jump_metrics_service.dart';

void main() {
  group('JumpMetricsService', () {
    test('computes CMJ flight time, height, and frame error', () {
      final metrics = JumpMetricsService.cmjFromFrames(
        takeoffFrame: 10,
        landingFrame: 46,
        fps: 120,
      );

      expect(metrics.flightTimeMs, closeTo(300, 0.001));
      expect(metrics.heightMeters, closeTo(0.1103625, 0.000001));
      expect(metrics.heightCm, closeTo(11.03625, 0.0001));
      expect(metrics.deltaHeightCm, greaterThan(0));
    });

    test('computes RSI from landing, takeoff, and landing frames', () {
      final metrics = JumpMetricsService.rsiFromFrames(
        landing1Frame: 5,
        takeoffFrame: 29,
        landing2Frame: 65,
        fps: 120,
      );

      expect(metrics.contactTimeMs, closeTo(200, 0.001));
      expect(metrics.flightTimeMs, closeTo(300, 0.001));
      expect(metrics.heightCm, closeTo(11.03625, 0.0001));
      expect(metrics.rsiScore, closeTo(0.5518125, 0.000001));
      expect(metrics.deltaRsi, greaterThan(0));
    });

    test('returns zero RSI error when one-frame contact is too short', () {
      final metrics = JumpMetricsService.rsiFromFrames(
        landing1Frame: 10,
        takeoffFrame: 11,
        landing2Frame: 47,
        fps: 120,
      );

      expect(metrics.contactTimeMs, closeTo(8.333, 0.001));
      expect(metrics.deltaRsi, 0);
    });

    test('computes fatigue loss against baseline', () {
      final loss = JumpMetricsService.fatigueLossPercent(
        baselineHeightCm: 40,
        currentHeightCm: 36,
      );

      expect(loss, closeTo(10, 0.001));
    });

    test('flags jump outliers and summarizes valid jumps', () {
      final summary = JumpMetricsService.summarizeJumps(
        const [
          JumpSample(heightCm: 30, deltaHeightCm: 0.5),
          JumpSample(heightCm: 31, deltaHeightCm: 0.5),
          JumpSample(heightCm: 50, deltaHeightCm: 0.5),
        ],
      );

      expect(summary.outlierFlags, [false, false, true]);
      expect(summary.averageHeightCm, closeTo(30.5, 0.001));
      expect(summary.propagatedErrorCm, closeTo(0.353553, 0.000001));
    });

    test('computes signed asymmetry and stronger leg', () {
      final metrics = JumpMetricsService.asymmetry(
        leftHeightCm: 28,
        rightHeightCm: 35,
      );

      expect(metrics.percent, closeTo(20, 0.001));
      expect(metrics.strongerLeg, 'right');

      final leftStronger = JumpMetricsService.asymmetry(
        leftHeightCm: 35,
        rightHeightCm: 28,
      );

      expect(leftStronger.percent, closeTo(-20, 0.001));
      expect(leftStronger.strongerLeg, 'left');
    });

    test('rejects invalid frame ordering', () {
      expect(
        () => JumpMetricsService.cmjFromFrames(
          takeoffFrame: 12,
          landingFrame: 12,
          fps: 120,
        ),
        throwsArgumentError,
      );
    });
  });
}
