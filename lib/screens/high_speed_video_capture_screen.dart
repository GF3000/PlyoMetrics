import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../l10n/app_localizations.dart';

class HighSpeedVideoCaptureScreen extends StatefulWidget {
  const HighSpeedVideoCaptureScreen({super.key});

  @override
  State<HighSpeedVideoCaptureScreen> createState() =>
      _HighSpeedVideoCaptureScreenState();
}

class _HighSpeedVideoCaptureScreenState
    extends State<HighSpeedVideoCaptureScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  int _targetFps = 120;
  bool _initializing = true;
  bool _recording = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    unawaited(_handleLifecycleState(state));
  }

  Future<void> _handleLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      final controller = _controller;
      _controller = null;
      if (controller != null) {
        try {
          if (_recording && controller.value.isRecordingVideo) {
            await controller.stopVideoRecording();
          }
        } on CameraException {
          // The OS may already have reclaimed the camera.
        }
        await controller.dispose();
      }
      if (mounted) {
        setState(() {
          _recording = false;
          _initializing = true;
        });
      }
    } else if (state == AppLifecycleState.resumed) {
      await _initializeCamera();
    }
  }

  Future<void> _initializeCamera({bool allowFpsFallback = true}) async {
    setState(() {
      _initializing = true;
      _errorMessage = null;
    });

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) {
          final l = AppLocalizations.of(context)!;
          setState(() {
            _initializing = false;
            _errorMessage = l.cameraUnavailable;
          });
        }
        return;
      }

      final preferred = cameras.where(
        (camera) => camera.lensDirection == CameraLensDirection.back,
      );
      final camera = preferred.isNotEmpty ? preferred.first : cameras.first;
      final previous = _controller;
      final controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
        fps: _targetFps,
      );
      _controller = controller;
      await previous?.dispose();
      await controller.initialize();
      await controller.prepareForVideoRecording();

      if (mounted) {
        setState(() => _initializing = false);
      }
    } on CameraException catch (error) {
      if (_targetFps == 120 && allowFpsFallback && mounted) {
        setState(() => _targetFps = 60);
        await _initializeCamera(allowFpsFallback: false);
        return;
      }
      if (mounted) {
        final l = AppLocalizations.of(context)!;
        setState(() {
          _initializing = false;
          _errorMessage = error.description ?? l.cameraInitializationFailed;
        });
      }
    }
  }

  Future<void> _toggleRecording() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    try {
      if (_recording) {
        final video = await controller.stopVideoRecording();
        if (!mounted) return;
        setState(() => _recording = false);
        Navigator.of(context).pop(video.path);
      } else {
        await controller.startVideoRecording();
        if (mounted) setState(() => _recording = true);
      }
    } on CameraException catch (error) {
      if (!mounted) return;
      setState(() {
        _recording = false;
        _errorMessage = error.description ?? error.code;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final controller = _controller;
    final ready =
        controller != null && controller.value.isInitialized && !_initializing;

    return PopScope(
      canPop: !_recording,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(title: Text(l.highSpeedRecording)),
        body: Column(
          children: [
            Expanded(
              child: ready
                  ? Center(
                      child: AspectRatio(
                        aspectRatio: controller.value.aspectRatio,
                        child: CameraPreview(controller),
                      ),
                    )
                  : Center(
                      child: _errorMessage != null
                          ? Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                _errorMessage!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.redAccent),
                              ),
                            )
                          : const CircularProgressIndicator(
                              color: AppColors.brand,
                            ),
                    ),
            ),
            SafeArea(
              top: false,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppColors.card,
                  border: Border(top: BorderSide(color: AppColors.borderLight)),
                ),
                child: Column(
                  children: [
                    Text(
                      l.targetFrameRate,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<int>(
                      segments: const [
                        ButtonSegment(value: 60, label: Text('60 FPS')),
                        ButtonSegment(value: 120, label: Text('120 FPS')),
                      ],
                      selected: {_targetFps},
                      onSelectionChanged: _recording || _initializing
                          ? null
                          : (selection) {
                              final fps = selection.first;
                              if (fps == _targetFps) return;
                              setState(() => _targetFps = fps);
                              _initializeCamera();
                            },
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: ready ? _toggleRecording : null,
                        icon: Icon(
                          _recording ? Icons.stop : Icons.fiber_manual_record,
                        ),
                        label: Text(
                          _recording ? l.stopRecording : l.startRecording,
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: _recording
                              ? Colors.redAccent
                              : AppColors.brand,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
