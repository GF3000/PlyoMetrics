import 'package:plyometrics/core/frame_timing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses valid rational and decimal frame rates', () {
    expect(parseFrameRate('120/1'), 120);
    expect(parseFrameRate('30000/1001'), closeTo(29.970, 0.001));
    expect(parseFrameRate('60'), 60);
  });

  test('rejects invalid frame rates', () {
    expect(parseFrameRate(null), isNull);
    expect(parseFrameRate('0/0'), isNull);
    expect(parseFrameRate('-60/1'), isNull);
  });

  test('uses probed timestamps when every extracted frame has one', () {
    expect(
      alignFrameTimestamps(
        frameCount: 3,
        probedTimestamps: [1.0, 1.01, 1.025],
        startTimeSeconds: 1,
        fallbackFps: 120,
      ),
      [1.0, 1.01, 1.025],
    );
  });

  test('sorts timestamps and removes frames before the extraction window', () {
    expect(
      alignFrameTimestamps(
        frameCount: 3,
        probedTimestamps: [1.02, 0.95, 1.0, 1.01, 1.01],
        startTimeSeconds: 1,
        fallbackFps: 120,
      ),
      [1.0, 1.01, 1.02],
    );
  });

  test(
    'falls back to constant frame timing when probe output is incomplete',
    () {
      final result = alignFrameTimestamps(
        frameCount: 3,
        probedTimestamps: [1.0],
        startTimeSeconds: 1,
        fallbackFps: 100,
      );

      expect(result[0], 1);
      expect(result[1], closeTo(1.01, 0.0001));
      expect(result[2], closeTo(1.02, 0.0001));
    },
  );
}
