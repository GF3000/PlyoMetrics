import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/frame_timing.dart';
import '../models/video_frame_sample.dart';

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
      developer.log(
        'getFramerate: FFprobe returned null info.\nLogs:\n$logText',
        name: _tag,
        level: 900,
      );
      throw Exception('Could not read video metadata. Check console logs.');
    }

    developer.log(
      'getFramerate: format=${info.getFormat()}, duration=${info.getDuration()}, streams=${info.getStreams().length}',
      name: _tag,
    );

    final streams = info.getStreams();
    final videoStream = streams.firstWhere(
      (s) => s.getType() == 'video',
      orElse: () {
        final types = streams.map((s) => s.getType()).toList();
        developer.log(
          'getFramerate: no video stream found. Stream types: $types',
          name: _tag,
          level: 900,
        );
        throw Exception('No video stream found (types: $types)');
      },
    );

    final averageFrameRate = videoStream.getAverageFrameRate();
    final realFrameRate = videoStream.getRealFrameRate();
    developer.log(
      'getFramerate: avg_frame_rate=$averageFrameRate, '
      'r_frame_rate=$realFrameRate',
      name: _tag,
    );
    final fps =
        parseFrameRate(averageFrameRate) ?? parseFrameRate(realFrameRate);
    if (fps == null) {
      throw Exception('Could not determine a valid framerate');
    }
    developer.log('getFramerate: parsed fps=$fps', name: _tag);
    return fps;
  }

  /// Extracts ~2 seconds of frames starting at [startTimeSeconds]
  /// into [outputDir]. Calls [onProgress] with values 0.0–1.0.
  /// Returns the sorted list of extracted frame file paths.
  Future<List<VideoFrameSample>> extractFrames({
    required String videoPath,
    required double startTimeSeconds,
    required String outputDir,
    required double fallbackFps,
    required void Function(double progress) onProgress,
  }) async {
    // Clear output directory first
    final dir = Directory(outputDir);
    if (await dir.exists()) await dir.delete(recursive: true);
    await dir.create(recursive: true);

    List<double> timestamps = const [];
    try {
      timestamps = await _getFrameTimestamps(
        videoPath: videoPath,
        startTimeSeconds: startTimeSeconds,
      );
    } catch (error, stackTrace) {
      developer.log(
        'Frame timestamp probe failed, using CFR fallback: $error',
        name: _tag,
        level: 800,
        stackTrace: stackTrace,
      );
    }

    final command =
        '-threads 0 '
        '-ss $startTimeSeconds '
        '-t 2 '
        '-i "$videoPath" '
        '-map 0:v:0 '
        '-fps_mode passthrough '
        '-vf scale=720:-2 '
        '-q:v 5 '
        '"$outputDir/frame_%04d.jpg"';

    developer.log(
      'extractFrames: running command:\nffmpeg $command',
      name: _tag,
    );

    final completer = Completer<void>();

    final session = await FFmpegKit.executeAsync(
      command,
      (completedSession) async {
        final returnCode = await completedSession.getReturnCode();
        developer.log(
          'extractFrames: returnCode=${returnCode?.getValue()}',
          name: _tag,
        );

        if (ReturnCode.isSuccess(returnCode)) {
          if (!completer.isCompleted) completer.complete();
        } else {
          final logs = await completedSession.getAllLogs();
          final logText = logs.map((l) => l.getMessage()).join('\n');
          developer.log(
            'extractFrames: FAILED.\nFull FFmpeg log:\n$logText',
            name: _tag,
            level: 900,
          );
          if (!completer.isCompleted) {
            completer.completeError(
              Exception(
                'Frame extraction failed '
                '(rc=${returnCode?.getValue()}). See console logs.',
              ),
            );
          }
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

    await completer.future.timeout(
      const Duration(seconds: 45),
      onTimeout: () async {
        await session.cancel();
        throw TimeoutException('Frame extraction timed out.');
      },
    );

    // List and sort extracted frames
    final files = await dir.list().toList();
    final jpgFiles =
        files.whereType<File>().where((f) => f.path.endsWith('.jpg')).toList()
          ..sort((a, b) => a.path.compareTo(b.path));

    developer.log(
      'extractFrames: extracted ${jpgFiles.length} frames to $outputDir',
      name: _tag,
    );

    final frameTimestamps = alignFrameTimestamps(
      frameCount: jpgFiles.length,
      probedTimestamps: timestamps,
      startTimeSeconds: startTimeSeconds,
      fallbackFps: fallbackFps,
    );

    return [
      for (int index = 0; index < jpgFiles.length; index++)
        VideoFrameSample(
          index: index,
          path: jpgFiles[index].path,
          timestampSeconds: frameTimestamps[index],
        ),
    ];
  }

  Future<List<double>> _getFrameTimestamps({
    required String videoPath,
    required double startTimeSeconds,
  }) async {
    final command =
        '-v error '
        '-select_streams v:0 '
        '-read_intervals "$startTimeSeconds%+2" '
        '-show_entries frame=best_effort_timestamp_time '
        '-of csv=p=0 '
        '"$videoPath"';
    final completer = Completer<void>();
    final session = await FFprobeKit.executeAsync(command, (completedSession) {
      if (!completer.isCompleted) completer.complete();
    });

    await completer.future.timeout(
      const Duration(seconds: 20),
      onTimeout: () async {
        await session.cancel();
        throw TimeoutException('Frame timestamp probe timed out.');
      },
    );

    final returnCode = await session.getReturnCode();
    if (!ReturnCode.isSuccess(returnCode)) {
      throw Exception(
        'Frame timestamp probe failed (rc=${returnCode?.getValue()}).',
      );
    }

    final output = await session.getOutput();
    return (output ?? '')
        .split(RegExp(r'\r?\n'))
        .map((line) => double.tryParse(line.trim()))
        .whereType<double>()
        .toList();
  }
}
