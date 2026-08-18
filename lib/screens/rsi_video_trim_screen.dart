import 'dart:io';

import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

import '../core/theme.dart';
import '../providers/rsi_session_provider.dart';
import 'cmj_video_scrubber_screen.dart';
import 'high_speed_video_capture_screen.dart';

/// Phase 1 for RSI: Coarse video selection.
/// User picks a video, plays it, pauses near the drop jump, then taps
/// "Analyze Jump from Here" to extract a 2-second window in RSI mode.
class RsiVideoTrimScreen extends StatefulWidget {
  const RsiVideoTrimScreen({super.key});

  @override
  State<RsiVideoTrimScreen> createState() => _RsiVideoTrimScreenState();
}

class _RsiVideoTrimScreenState extends State<RsiVideoTrimScreen> {
  VideoPlayerController? _controller;
  String? _videoPath;
  bool _isInitializing = false;
  String? _errorMessage;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    final picker = ImagePicker();
    final file = await picker.pickVideo(source: ImageSource.gallery);
    if (file == null) return;
    await _loadVideo(file.path);
  }

  Future<void> _recordVideo() async {
    final path = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const HighSpeedVideoCaptureScreen()),
    );
    if (path != null && mounted) {
      await _loadVideo(path);
    }
  }

  Future<void> _loadVideo(String path) async {
    final l = AppLocalizations.of(context)!;
    setState(() {
      _isInitializing = true;
      _errorMessage = null;
    });

    try {
      final previous = _controller;
      final controller = VideoPlayerController.file(File(path));
      await controller.initialize();
      controller.addListener(() {
        if (mounted) setState(() {});
      });
      await previous?.dispose();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _videoPath = path;
        _controller = controller;
        _isInitializing = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _isInitializing = false;
          _errorMessage = l.operationFailed;
        });
      }
    }
  }

  Future<void> _analyzeFromHere() async {
    final controller = _controller;
    if (controller == null || _videoPath == null) return;

    final positionMs = controller.value.position.inMilliseconds;
    final startTime = (positionMs / 1000.0 - 0.5).clamp(0.0, double.infinity);

    await controller.pause();

    if (!mounted) return;

    final result = await Navigator.of(context).push<RsiJumpResult>(
      MaterialPageRoute(
        builder: (_) => CmjVideoScrubberScreen(
          videoPath: _videoPath!,
          startTimeSeconds: startTime,
          mode: ScrubberMode.rsi,
        ),
      ),
    );

    if (result != null && mounted) {
      Navigator.of(context).pop(result);
    }
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final millis = (d.inMilliseconds.remainder(1000) ~/ 10).toString().padLeft(
      2,
      '0',
    );
    return '$minutes:$seconds.$millis';
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final controller = _controller;
    final isReady = controller != null && controller.value.isInitialized;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(
          l.selectJumpMoment,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // Video preview
          Expanded(
            child: isReady
                ? Center(
                    child: AspectRatio(
                      aspectRatio: controller.value.aspectRatio,
                      child: VideoPlayer(controller),
                    ),
                  )
                : Center(
                    child: _isInitializing
                        ? const CircularProgressIndicator(
                            color: AppColors.brand,
                          )
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.videocam_outlined,
                                size: 64,
                                color: AppColors.textTertiary,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _errorMessage ?? l.pickDropJumpVideo,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                  ),
          ),

          // Controls section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.card,
              border: Border(top: BorderSide(color: AppColors.borderLight)),
            ),
            child: Column(
              children: [
                if (isReady) ...[
                  // Seek slider
                  SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: AppColors.brand,
                      inactiveTrackColor: AppColors.borderLight,
                      thumbColor: AppColors.brand,
                      overlayColor: AppColors.brand.withAlpha(40),
                      trackHeight: 3,
                    ),
                    child: Slider(
                      value: controller.value.position.inMilliseconds
                          .toDouble()
                          .clamp(
                            0,
                            controller.value.duration.inMilliseconds.toDouble(),
                          ),
                      max: controller.value.duration.inMilliseconds.toDouble(),
                      onChanged: (value) {
                        controller.seekTo(
                          Duration(milliseconds: value.toInt()),
                        );
                      },
                    ),
                  ),

                  // Time + play/pause
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(controller.value.position),
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          controller.value.isPlaying
                              ? controller.pause()
                              : controller.play();
                        },
                        icon: Icon(
                          controller.value.isPlaying
                              ? Icons.pause_circle_filled
                              : Icons.play_circle_filled,
                          color: AppColors.brand,
                          size: 48,
                        ),
                      ),
                      Text(
                        _formatDuration(controller.value.duration),
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Analyze button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _analyzeFromHere,
                      icon: const Icon(Icons.precision_manufacturing),
                      label: Text(l.analyzeJumpFromHere),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.brand,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _isInitializing ? null : _recordVideo,
                      icon: const Icon(Icons.videocam),
                      label: Text(l.recordHighSpeedVideo),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.brand,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _isInitializing ? null : _pickVideo,
                      icon: const Icon(Icons.video_library),
                      label: Text(l.pickVideoFromGallery),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.brand,
                        side: const BorderSide(color: AppColors.brand),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
