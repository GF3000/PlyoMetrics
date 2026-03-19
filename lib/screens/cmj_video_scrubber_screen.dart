import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../core/theme.dart';
import '../providers/cmj_session_provider.dart';
import '../providers/rsi_session_provider.dart';
import '../services/video_service.dart';

enum ScrubberMode { cmj, rsi }

/// Phase 2: Fine frame-by-frame scrubber.
/// Extracts frames via FFmpeg, then lets the user mark takeoff/landing
/// with single-frame precision.
/// In RSI mode, captures 3 frames: Landing 1, Takeoff, Landing 2.
class CmjVideoScrubberScreen extends ConsumerStatefulWidget {
  final String videoPath;
  final double startTimeSeconds;
  final ScrubberMode mode;

  const CmjVideoScrubberScreen({
    super.key,
    required this.videoPath,
    required this.startTimeSeconds,
    this.mode = ScrubberMode.cmj,
  });

  @override
  ConsumerState<CmjVideoScrubberScreen> createState() =>
      _CmjVideoScrubberScreenState();
}

class _CmjVideoScrubberScreenState
    extends ConsumerState<CmjVideoScrubberScreen> {
  // Extraction state
  bool _isExtracting = true;
  double _extractionProgress = 0.0;
  String? _errorMessage;

  // Frame data
  List<String> _framePaths = [];
  double _fps = 0;
  int _currentFrame = 0;

  // Marking state
  int? _takeoffFrame;
  int? _landingFrame;
  int? _landing1Frame; // RSI only: first ground contact

  // Playback state
  bool _isPlaying = false;
  Timer? _playTimer;
  Timer? _longPressTimer;

  // Temp directory for cleanup
  String? _tempDir;

  @override
  void initState() {
    super.initState();
    _startExtraction();
  }

  @override
  void dispose() {
    _stopPlayback();
    _longPressTimer?.cancel();
    _cleanupTempFiles();
    super.dispose();
  }

  Future<void> _cleanupTempFiles() async {
    if (_tempDir != null) {
      final dir = Directory(_tempDir!);
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
    }
  }

  Future<void> _startExtraction() async {
    const tag = 'CmjScrubber';
    try {
      final videoService = ref.read(videoServiceProvider);

      developer.log(
          'Starting extraction: path="${widget.videoPath}", startTime=${widget.startTimeSeconds}s',
          name: tag);

      // Get framerate
      _fps = await videoService.getFramerate(widget.videoPath);
      developer.log('Framerate detected: $_fps FPS', name: tag);

      // Prepare temp directory
      final tempBase = await getTemporaryDirectory();
      final sessionId = DateTime.now().millisecondsSinceEpoch;
      _tempDir = '${tempBase.path}/plyometrics_frames_$sessionId';
      developer.log('Temp dir: $_tempDir', name: tag);

      // Extract frames
      final frames = await videoService.extractFrames(
        videoPath: widget.videoPath,
        startTimeSeconds: widget.startTimeSeconds,
        outputDir: _tempDir!,
        onProgress: (progress) {
          if (mounted) {
            setState(() => _extractionProgress = progress);
          }
        },
      );

      developer.log('Extraction complete: ${frames.length} frames', name: tag);

      if (mounted) {
        setState(() {
          _framePaths = frames;
          _isExtracting = false;
        });
      }
    } catch (e, stackTrace) {
      developer.log('Extraction FAILED: $e\n$stackTrace',
          name: tag, level: 900);
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isExtracting = false;
        });
      }
    }
  }

  void _togglePlayback() {
    if (_isPlaying) {
      _stopPlayback();
    } else {
      if (_currentFrame >= _framePaths.length - 1) return;
      setState(() => _isPlaying = true);
      final interval = Duration(milliseconds: (1000 / _fps).round());
      _playTimer = Timer.periodic(interval, (_) {
        if (!mounted || _currentFrame >= _framePaths.length - 1) {
          _stopPlayback();
          return;
        }
        setState(() => _currentFrame++);
      });
    }
  }

  void _stopPlayback() {
    _playTimer?.cancel();
    _playTimer = null;
    if (mounted) {
      setState(() => _isPlaying = false);
    }
  }

  void _startLongPress(int delta) {
    _stopPlayback();
    _longPressTimer = Timer.periodic(
      const Duration(milliseconds: 50),
      (_) {
        final next = _currentFrame + delta;
        if (next < 0 || next >= _framePaths.length) {
          _longPressTimer?.cancel();
          return;
        }
        if (mounted) setState(() => _currentFrame = next);
      },
    );
  }

  void _stopLongPress() {
    _longPressTimer?.cancel();
    _longPressTimer = null;
  }

  void _confirmSelection() {
    if (widget.mode == ScrubberMode.rsi) {
      _confirmRsiSelection();
    } else {
      _confirmCmjSelection();
    }
  }

  void _confirmCmjSelection() {
    if (_takeoffFrame == null || _landingFrame == null) return;
    if (_landingFrame! <= _takeoffFrame!) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Landing frame must be after takeoff frame'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final flightTimeSec = (_landingFrame! - _takeoffFrame!) / _fps;
    final flightTimeMs = flightTimeSec * 1000;
    const g = 9.81;
    final heightMeters = g * flightTimeSec * flightTimeSec / 8;
    final heightCm = heightMeters * 100;
    final deltaHCm = JumpResult.computeDeltaH(heightMeters, _fps);

    final result = JumpResult(
      takeoffFrame: _takeoffFrame!,
      landingFrame: _landingFrame!,
      fps: _fps,
      flightTimeMs: flightTimeMs,
      heightCm: heightCm,
      deltaHCm: deltaHCm,
      videoPath: widget.videoPath,
    );

    Navigator.of(context).pop(result);
  }

  void _confirmRsiSelection() {
    if (_landing1Frame == null ||
        _takeoffFrame == null ||
        _landingFrame == null) {
      return;
    }
    if (!(_landing1Frame! < _takeoffFrame! &&
        _takeoffFrame! < _landingFrame!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Frames must be in order: Landing 1 < Takeoff < Landing 2'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final result = RsiJumpResult.fromFrames(
      landing1Frame: _landing1Frame!,
      takeoffFrame: _takeoffFrame!,
      landing2Frame: _landingFrame!,
      fps: _fps,
      dropHeightCm: 0, // set by the test screen
      videoPath: widget.videoPath,
    );

    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text(
          'Frame Analysis',
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
      body: _isExtracting
          ? _buildExtractionProgress()
          : _errorMessage != null
              ? _buildError()
              : _buildScrubber(),
    );
  }

  Widget _buildExtractionProgress() {
    final percent = (_extractionProgress * 100).toInt();
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.auto_fix_high,
              size: 48,
              color: AppColors.brand,
            ),
            const SizedBox(height: 24),
            const Text(
              'Extracting Frames',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Processing video at ${_fps > 0 ? '${_fps.toStringAsFixed(0)} FPS' : '...'}',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _extractionProgress,
                minHeight: 8,
                backgroundColor: AppColors.borderLight,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.brand),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '$percent%',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.brand,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Extraction Failed',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScrubber() {
    if (_framePaths.isEmpty) {
      return const Center(
        child: Text(
          'No frames extracted',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    final frameCount = _framePaths.length;
    final currentTimeMs = (_currentFrame / _fps * 1000).toStringAsFixed(1);

    // Compute results based on mode
    final bool isRsi = widget.mode == ScrubberMode.rsi;
    double? flightTimeMs;
    double? heightCm;
    double? deltaHCm;
    double? contactTimeMs;
    double? rsiScore;
    final bool hasResults;

    if (isRsi) {
      hasResults = _landing1Frame != null &&
          _takeoffFrame != null &&
          _landingFrame != null &&
          _landing1Frame! < _takeoffFrame! &&
          _takeoffFrame! < _landingFrame!;
      if (hasResults) {
        const g = 9.81;
        final contactSec = (_takeoffFrame! - _landing1Frame!) / _fps;
        final flightSec = (_landingFrame! - _takeoffFrame!) / _fps;
        contactTimeMs = contactSec * 1000;
        flightTimeMs = flightSec * 1000;
        final heightMeters = g * flightSec * flightSec / 8;
        heightCm = heightMeters * 100;
        rsiScore = heightMeters / contactSec;
      }
    } else {
      hasResults = _takeoffFrame != null &&
          _landingFrame != null &&
          _landingFrame! > _takeoffFrame!;
      if (hasResults) {
        final flightTimeSec = (_landingFrame! - _takeoffFrame!) / _fps;
        flightTimeMs = flightTimeSec * 1000;
        const g = 9.81;
        final heightMeters = g * flightTimeSec * flightTimeSec / 8;
        heightCm = heightMeters * 100;
        deltaHCm = JumpResult.computeDeltaH(heightMeters, _fps);
      }
    }

    return Column(
      children: [
        // Frame image
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _takeoffFrame == _currentFrame
                    ? Colors.green
                    : _landingFrame == _currentFrame
                        ? Colors.red
                        : (isRsi && _landing1Frame == _currentFrame)
                            ? Colors.amber
                            : AppColors.borderLight,
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.file(
                File(_framePaths[_currentFrame]),
                fit: BoxFit.contain,
                width: double.infinity,
                gaplessPlayback: true,
              ),
            ),
          ),
        ),

        // Frame info
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Frame ${_currentFrame + 1} / $frameCount',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              Text(
                '${_fps.toStringAsFixed(0)} FPS',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.brand,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$currentTimeMs ms',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Step buttons + play/pause
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStepButton(
                icon: Icons.remove,
                enabled: _currentFrame > 0,
                onTap: () {
                  _stopPlayback();
                  setState(() => _currentFrame--);
                },
                onLongPressStart: () => _startLongPress(-1),
              ),
              const SizedBox(width: 24),
              IconButton(
                onPressed: _framePaths.isNotEmpty ? _togglePlayback : null,
                icon: Icon(
                  _isPlaying ? Icons.pause_circle : Icons.play_circle,
                  size: 40,
                ),
                color: AppColors.brand,
                disabledColor: AppColors.textTertiary,
                tooltip: _isPlaying ? 'Pause' : 'Play',
              ),
              const SizedBox(width: 24),
              _buildStepButton(
                icon: Icons.add,
                enabled: _currentFrame < frameCount - 1,
                onTap: () {
                  _stopPlayback();
                  setState(() => _currentFrame++);
                },
                onLongPressStart: () => _startLongPress(1),
              ),
            ],
          ),
        ),

        // Slider
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.brand,
              inactiveTrackColor: AppColors.borderLight,
              thumbColor: AppColors.brand,
              overlayColor: AppColors.brand.withAlpha(40),
              trackHeight: 3,
            ),
            child: Slider(
              value: _currentFrame.toDouble(),
              max: (frameCount - 1).toDouble(),
              divisions: frameCount > 1 ? frameCount - 1 : 1,
              onChanged: (value) {
                _stopPlayback();
                setState(() => _currentFrame = value.toInt());
              },
            ),
          ),
        ),

        // Controls section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: AppColors.card,
            border: Border(
              top: BorderSide(color: AppColors.borderLight),
            ),
          ),
          child: Column(
            children: [
              // Mark buttons
              if (isRsi)
                Row(
                  children: [
                    Expanded(
                      child: _buildMarkButton(
                        label: 'Landing 1',
                        icon: Icons.flight_land,
                        color: Colors.amber,
                        markedFrame: _landing1Frame,
                        onPressed: () =>
                            setState(() => _landing1Frame = _currentFrame),
                        compact: true,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _buildMarkButton(
                        label: 'Takeoff',
                        icon: Icons.flight_takeoff,
                        color: Colors.green,
                        markedFrame: _takeoffFrame,
                        onPressed: () =>
                            setState(() => _takeoffFrame = _currentFrame),
                        compact: true,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _buildMarkButton(
                        label: 'Landing 2',
                        icon: Icons.flight_land,
                        color: Colors.red,
                        markedFrame: _landingFrame,
                        onPressed: () =>
                            setState(() => _landingFrame = _currentFrame),
                        compact: true,
                      ),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: _buildMarkButton(
                        label: 'Mark Takeoff',
                        icon: Icons.flight_takeoff,
                        color: Colors.green,
                        markedFrame: _takeoffFrame,
                        onPressed: () =>
                            setState(() => _takeoffFrame = _currentFrame),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMarkButton(
                        label: 'Mark Landing',
                        icon: Icons.flight_land,
                        color: Colors.red,
                        markedFrame: _landingFrame,
                        onPressed: () =>
                            setState(() => _landingFrame = _currentFrame),
                      ),
                    ),
                  ],
                ),

              // Results summary
              if (hasResults) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: isRsi
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildMetric(
                              'Contact',
                              '${contactTimeMs!.toStringAsFixed(1)} ms',
                            ),
                            Container(
                                width: 1,
                                height: 32,
                                color: AppColors.borderLight),
                            _buildMetric(
                              'Flight',
                              '${flightTimeMs!.toStringAsFixed(1)} ms',
                            ),
                            Container(
                                width: 1,
                                height: 32,
                                color: AppColors.borderLight),
                            _buildMetric(
                              'Height',
                              '${heightCm!.toStringAsFixed(1)} cm',
                            ),
                            Container(
                                width: 1,
                                height: 32,
                                color: AppColors.borderLight),
                            _buildMetric(
                              'RSI',
                              rsiScore!.toStringAsFixed(2),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildMetric(
                              'Flight Time',
                              '${flightTimeMs!.toStringAsFixed(1)} ms',
                            ),
                            Container(
                              width: 1,
                              height: 32,
                              color: AppColors.borderLight,
                            ),
                            _buildMetric(
                              'Height',
                              '${heightCm!.toStringAsFixed(1)} cm',
                            ),
                            Container(
                              width: 1,
                              height: 32,
                              color: AppColors.borderLight,
                            ),
                            _buildMetric(
                              'Error',
                              '\u00b1 ${deltaHCm!.toStringAsFixed(1)} cm',
                            ),
                          ],
                        ),
                ),

                const SizedBox(height: 16),

                // Confirm button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _confirmSelection,
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Confirm Jump'),
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
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
    required VoidCallback onLongPressStart,
  }) {
    final color = enabled ? AppColors.brand : AppColors.textTertiary;
    return GestureDetector(
      onTap: enabled ? onTap : null,
      onLongPressStart: enabled ? (_) => onLongPressStart() : null,
      onLongPressEnd: (_) => _stopLongPress(),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, color: color),
      ),
    );
  }

  Widget _buildMarkButton({
    required String label,
    required IconData icon,
    required Color color,
    required int? markedFrame,
    required VoidCallback onPressed,
    bool compact = false,
  }) {
    final isMarked = markedFrame != null;
    final fontSize = compact ? 11.0 : 13.0;
    final hPadding = compact ? 4.0 : 8.0;
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: compact ? 14 : 18),
      label: Text(isMarked ? '$label (#${markedFrame + 1})' : label),
      style: OutlinedButton.styleFrom(
        foregroundColor: isMarked ? Colors.black : color,
        backgroundColor: isMarked ? color : Colors.transparent,
        side: BorderSide(color: color),
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: hPadding),
        textStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildMetric(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.brand,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
