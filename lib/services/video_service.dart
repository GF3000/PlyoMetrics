import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _tag = 'VideoService';

final videoServiceProvider = Provider<VideoService>((ref) => VideoService());

class VideoService {
  /// Returns the video framerate by probing with FFprobeKit.
  Future<double> getFramerate(String videoPath) async {
    developer.log('getFramerate: probing "$videoPath"', name: _tag);

    final session = await FFprobeKit.getMediaInformation(videoPath);
    final info = session.getMediaInformation();
    if (info == null) {
      final logs = await session.getAllLogs();
      final logText = logs.map((l) => l.getMessage()).join('\n');
      developer.log('getFramerate: FFprobe returned null info.\nLogs:\n$logText',
          name: _tag, level: 900);
      throw Exception('Could not read video metadata. Check console logs.');
    }

    developer.log(
        'getFramerate: format=${info.getFormat()}, duration=${info.getDuration()}, streams=${info.getStreams().length}',
        name: _tag);

    final streams = info.getStreams();
    final videoStream = streams.firstWhere(
      (s) => s.getType() == 'video',
      orElse: () {
        final types = streams.map((s) => s.getType()).toList();
        developer.log('getFramerate: no video stream found. Stream types: $types',
            name: _tag, level: 900);
        throw Exception('No video stream found (types: $types)');
      },
    );

    final rFrameRate = videoStream.getRealFrameRate();
    developer.log('getFramerate: r_frame_rate=$rFrameRate', name: _tag);
    if (rFrameRate == null) throw Exception('Could not determine framerate');

    final parts = rFrameRate.split('/');
    final fps = parts.length == 2
        ? double.parse(parts[0]) / double.parse(parts[1])
        : double.parse(parts[0]);
    developer.log('getFramerate: parsed fps=$fps', name: _tag);
    return fps;
  }

  /// Extracts ~2 seconds of frames starting at [startTimeSeconds]
  /// into [outputDir]. Calls [onProgress] with values 0.0–1.0.
  /// Returns the sorted list of extracted frame file paths.
  Future<List<String>> extractFrames({
    required String videoPath,
    required double startTimeSeconds,
    required String outputDir,
    required void Function(double progress) onProgress,
  }) async {
    // Clear output directory first
    final dir = Directory(outputDir);
    if (await dir.exists()) await dir.delete(recursive: true);
    await dir.create(recursive: true);

    final command = '-threads 0 '
        '-ss $startTimeSeconds '
        '-t 2 '
        '-i "$videoPath" '
        '-vf scale=240:-1 '
        '-q:v 10 '
        '"$outputDir/frame_%04d.jpg"';

    developer.log('extractFrames: running command:\nffmpeg $command', name: _tag);

    final completer = Completer<void>();

    await FFmpegKit.executeAsync(
      command,
      (completedSession) async {
        final returnCode = await completedSession.getReturnCode();
        developer.log('extractFrames: returnCode=${returnCode?.getValue()}',
            name: _tag);

        if (ReturnCode.isSuccess(returnCode)) {
          completer.complete();
        } else {
          final logs = await completedSession.getAllLogs();
          final logText = logs.map((l) => l.getMessage()).join('\n');
          developer.log('extractFrames: FAILED.\nFull FFmpeg log:\n$logText',
              name: _tag, level: 900);
          completer.completeError(Exception(
              'Frame extraction failed (rc=${returnCode?.getValue()}). See console logs.'));
        }
      },
      (log) {
        developer.log('FFmpeg: ${log.getMessage()}', name: _tag);
      },
      (statistics) {
        final time = statistics.getTime();
        if (time > 0) {
          onProgress((time / 2000).clamp(0.0, 1.0));
        }
      },
    );

    await completer.future;

    // List and sort extracted frames
    final files = await dir.list().toList();
    final jpgFiles = files
        .whereType<File>()
        .where((f) => f.path.endsWith('.jpg'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));

    developer.log('extractFrames: extracted ${jpgFiles.length} frames to $outputDir',
        name: _tag);

    return jpgFiles.map((f) => f.path).toList();
  }
}
