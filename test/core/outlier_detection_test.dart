import 'package:plyometrics/core/outlier_detection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('detectOutliers', () {
    test('keeps one and two measurement sessions valid', () {
      expect(detectOutliers([(value: 20, uncertainty: 0.5)]), [false]);
      expect(
        detectOutliers([
          (value: 20, uncertainty: 0.5),
          (value: 30, uncertainty: 0.5),
        ]),
        [false, false],
      );
    });

    test('isolates a single extreme result', () {
      expect(
        detectOutliers([
          (value: 20, uncertainty: 0.5),
          (value: 21, uncertainty: 0.5),
          (value: 40, uncertainty: 0.5),
        ]),
        [false, false, true],
      );
    });

    test('keeps a consistent three-jump set', () {
      expect(
        detectOutliers([
          (value: 30, uncertainty: 0.5),
          (value: 31, uncertainty: 0.5),
          (value: 29.5, uncertainty: 0.5),
        ]),
        [false, false, false],
      );
    });
  });
}
