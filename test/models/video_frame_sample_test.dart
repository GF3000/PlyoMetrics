import 'package:plyometrics/models/video_frame_sample.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('retains the presentation timestamp for a frame', () {
    const sample = VideoFrameSample(
      index: 12,
      path: 'frame_0012.jpg',
      timestampSeconds: 1.125,
    );

    expect(sample.index, 12);
    expect(sample.path, 'frame_0012.jpg');
    expect(sample.timestampSeconds, 1.125);
    expect(
      sample,
      const VideoFrameSample(
        index: 12,
        path: 'frame_0012.jpg',
        timestampSeconds: 1.125,
      ),
    );
  });
}
