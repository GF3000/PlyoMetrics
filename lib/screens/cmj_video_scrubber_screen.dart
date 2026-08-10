import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../core/theme.dart';
import '../providers/cmj_session_provider.dart';
import '../providers/rsi_session_provider.dart';
import '../services/jump_metrics_service.dart';
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
      developer.log('Extraction FAILED: $e\n$stackTrace', name: tag, level: 900);
      if (mounted) {
        setState(() {
          _errorMessage = AppLocalizations.of(context)!.videoExtractionHelp;
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
      final l = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.landingFrameAfterTakeoff),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final metrics = JumpMetricsService.cmjFromFrames(
      takeoffFrame: _takeoffFrame!,
      landingFrame: _landingFrame!,
      fps: _fps,
    );

    final result = JumpResult(
      takeoffFrame: _takeoffFrame!,
      landingFrame: _landingFrame!,
      fps: _fps,
      flightTimeMs: metrics.flightTimeMs,
      heightCm: metrics.heightCm,
      deltaHCm: metrics.deltaHeightCm,
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
      final l = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(l.framesInOrder),
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
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(
          l.frameAnalysis,
          style: const TextStyle(
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
    final l = AppLocalizations.of(context)!;
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
            Text(
              l.extractingFrames,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _fps > 0 ? l.processingVideoAtFps(_fps.toStringAsFixed(0)) : l.processingVideo,
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
              l.percentValue(percent),
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
    final l = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              l.extractionFailed,
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
              child: Text(l.goBack),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScrubber() {
    final l = AppLocalizations.of(context)!;
    if (_framePaths.isEmpty) {
      return Center(
        child: Text(
          l.noFramesExtracted,
          style: const TextStyle(color: AppColors.textSecondary),
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
        final metrics = JumpMetricsService.rsiFromFrames(
          landing1Frame: _landing1Frame!,
          takeoffFrame: _takeoffFrame!,
          landing2Frame: _landingFrame!,
          fps: _fps,
        );
        contactTimeMs = metrics.contactTimeMs;
        flightTimeMs = metrics.flightTimeMs;
        heightCm = metrics.heightCm;
        rsiScore = metrics.rsiScore;
      }
    } else {
      hasResults = _takeoffFrame != null &&
          _landingFrame != null &&
          _landingFrame! > _takeoffFrame!;
      if (hasResults) {
        final metrics = JumpMetricsService.cmjFromFrames(
          takeoffFrame: _takeoffFrame!,
          landingFrame: _landingFrame!,
          fps: _fps,
        );
        flightTimeMs = metrics.flightTimeMs;
        heightCm = metrics.heightCm;
        deltaHCm = metrics.deltaHeightCm;
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
                l.frameCounter(_currentFrame + 1, frameCount),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              Text(
                l.fpsDisplay(_fps.toStringAsFixed(0)),
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.brand,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                l.msDisplay(currentTimeMs),
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
                tooltip: _isPlaying ? l.pause : l.play,
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
              Text(
                isRsi
                    ? l.rsiFrameSelectionInstructions
                    : l.cmjFrameSelectionInstructions,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 12),
              // Mark buttons
              if (isRsi)
                Row(
                  children: [
                    Expanded(
                      child: _buildMarkButton(
                        label: l.landing1,
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
                        label: l.takeoff,
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
                        label: l.landing2,
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
                        label: l.markTakeoff,
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
                        label: l.markLanding,
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
                              l.contact,
                              '${contactTimeMs!.toStringAsFixed(1)} ms',
                            ),
                            Container(
                                width: 1,
                                height: 32,
                                color: AppColors.borderLight),
                            _buildMetric(
                              l.flight,
                              '${flightTimeMs!.toStringAsFixed(1)} ms',
                            ),
                            Container(
                                width: 1,
                                height: 32,
                                color: AppColors.borderLight),
                            _buildMetric(
                              l.height,
                              '${heightCm!.toStringAsFixed(1)} cm',
                            ),
                            Container(
                                width: 1,
                                height: 32,
                                color: AppColors.borderLight),
                            _buildMetric(
                              l.rsi,
                              rsiScore!.toStringAsFixed(2),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildMetric(
                              l.flightTime,
                              '${flightTimeMs!.toStringAsFixed(1)} ms',
                            ),
                            Container(
                              width: 1,
                              height: 32,
                              color: AppColors.borderLight,
                            ),
                            _buildMetric(
                              l.height,
                              '${heightCm!.toStringAsFixed(1)} cm',
                            ),
                            Container(
                              width: 1,
                              height: 32,
                              color: AppColors.borderLight,
                            ),
                            _buildMetric(
                              l.errorMarginLabel,
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
                    label: Text(l.confirmJump),
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
    final l = AppLocalizations.of(context)!;
    final isMarked = markedFrame != null;
    final fontSize = compact ? 11.0 : 13.0;
    final hPadding = compact ? 4.0 : 8.0;
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: compact ? 14 : 18),
      label: Text(isMarked ? l.markButtonLabeled(label, markedFrame + 1) : label),
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
