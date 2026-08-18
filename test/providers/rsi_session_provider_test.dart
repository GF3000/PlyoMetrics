import 'package:plyometrics/providers/rsi_session_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('uses presentation timestamps for RSI timing', () {
    final result = RsiJumpResult.fromFrames(
      landing1Frame: 10,
      takeoffFrame: 20,
      landing2Frame: 50,
      fps: 120,
      dropHeightCm: 30,
      videoPath: 'jump.mp4',
      landing1TimeSeconds: 1,
      takeoffTimeSeconds: 1.12,
      landing2TimeSeconds: 1.39,
    );

    expect(result.contactTimeMs, closeTo(120, 0.001));
    expect(result.flightTimeMs, closeTo(270, 0.001));
    expect(result.landing1TimeSeconds, 1);
    expect(result.takeoffTimeSeconds, 1.12);
    expect(result.landing2TimeSeconds, 1.39);
  });

  test('maps RSI thresholds to stable quality levels', () {
    expect(rsiQuality(1.2).level, RsiQualityLevel.needsImprovement);
    expect(rsiQuality(1.7).level, RsiQualityLevel.fair);
    expect(rsiQuality(2.2).level, RsiQualityLevel.good);
    expect(rsiQuality(2.7).level, RsiQualityLevel.excellent);
    expect(rsiQuality(3.1).level, RsiQualityLevel.elite);
  });

  test('uses local frame duration for VFR uncertainty', () {
    final constantRate = RsiJumpResult.fromFrames(
      landing1Frame: 10,
      takeoffFrame: 20,
      landing2Frame: 50,
      fps: 30,
      dropHeightCm: 30,
      videoPath: 'jump.mp4',
    );
    final timestampAware = RsiJumpResult.fromFrames(
      landing1Frame: 10,
      takeoffFrame: 20,
      landing2Frame: 50,
      fps: 30,
      dropHeightCm: 30,
      videoPath: 'jump.mp4',
      frameDurationSeconds: 0.005,
    );

    expect(timestampAware.deltaRsi, lessThan(constantRate.deltaRsi));
  });
}
