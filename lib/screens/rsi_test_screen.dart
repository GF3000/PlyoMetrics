import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme.dart';
import '../models/jump_test.dart';
import '../providers/management_providers.dart';
import '../providers/rsi_session_provider.dart';
import 'rsi_video_trim_screen.dart';

class RsiTestScreen extends ConsumerStatefulWidget {
  const RsiTestScreen({super.key});

  @override
  ConsumerState<RsiTestScreen> createState() => _RsiTestScreenState();
}

class _RsiTestScreenState extends ConsumerState<RsiTestScreen> {
  RsiJumpResult? _result;
  bool _isSaving = false;

  Future<void> _recordJump() async {
    final result = await Navigator.of(context).push<RsiJumpResult>(
      MaterialPageRoute(builder: (_) => const RsiVideoTrimScreen()),
    );
    if (result == null || !mounted) return;

    // Re-create result with the selected drop height
    final dropHeight = ref.read(rsiSessionProvider).dropHeightCm;
    final adjusted = RsiJumpResult(
      landing1Frame: result.landing1Frame,
      takeoffFrame: result.takeoffFrame,
      landing2Frame: result.landing2Frame,
      fps: result.fps,
      contactTimeMs: result.contactTimeMs,
      flightTimeMs: result.flightTimeMs,
      heightCm: result.heightCm,
      rsiScore: result.rsiScore,
      deltaRsi: result.deltaRsi,
      dropHeightCm: dropHeight,
      videoPath: result.videoPath,
    );

    setState(() => _result = adjusted);
  }

  Future<void> _saveTest() async {
    if (_result == null) return;
    setState(() => _isSaving = true);

    final athlete = ref.read(activeAthleteProvider)!;
    final r = _result!;
    final test = JumpTest()
      ..athleteId = athlete.id
      ..testType = 'rsi'
      ..timestamp = DateTime.now()
      ..landing1Frame = r.landing1Frame
      ..takeoffFrame = r.takeoffFrame
      ..landingFrame = r.landing2Frame
      ..fps = r.fps
      ..flightTimeMs = r.flightTimeMs
      ..heightCm = r.heightCm
      ..deltaHCm = 0.0
      ..contactTimeMs = r.contactTimeMs
      ..rsiScore = r.rsiScore
      ..deltaRsi = r.deltaRsi
      ..dropHeightCm = r.dropHeightCm;

    await ref.read(isarServiceProvider).saveJumpTests([test]);

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _discard() {
    setState(() => _result = null);
  }

  @override
  Widget build(BuildContext context) {
    final athlete = ref.watch(activeAthleteProvider);
    final dropHeight = ref.watch(rsiSessionProvider).dropHeightCm;
    final hasResult = _result != null;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text(
          'RSI Drop Jump',
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Athlete name
              if (athlete != null)
                Text(
                  athlete.name,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              const SizedBox(height: 20),

              // Drop height selector
              _buildDropHeightSelector(dropHeight),
              const SizedBox(height: 28),

              // Metric cards
              _buildMetricCards(),
              const SizedBox(height: 32),

              // RSI score display
              _buildRsiScoreDisplay(),
              const SizedBox(height: 32),

              // Action buttons
              _buildActionButtons(hasResult),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropHeightSelector(double current) {
    const heights = [20.0, 30.0, 40.0, 50.0];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'DROP HEIGHT',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        SegmentedButton<double>(
          segments: heights
              .map((h) => ButtonSegment(
                    value: h,
                    label: Text('${h.toInt()} cm'),
                  ))
              .toList(),
          selected: {current},
          onSelectionChanged: (set) {
            ref.read(rsiSessionProvider.notifier).setDropHeight(set.first);
          },
          style: SegmentedButton.styleFrom(
            selectedBackgroundColor: AppColors.brand,
            selectedForegroundColor: Colors.black,
            foregroundColor: AppColors.textSecondary,
            backgroundColor: AppColors.card,
            side: const BorderSide(color: AppColors.borderLight),
            textStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCards() {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            icon: Icons.bolt,
            label: 'CONTACT TIME',
            value: _result != null
                ? '${_result!.contactTimeMs.toStringAsFixed(0)} ms'
                : '--',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            icon: Icons.expand_less,
            label: 'FLIGHT TIME',
            value: _result != null
                ? '${_result!.flightTimeMs.toStringAsFixed(0)} ms'
                : '--',
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.brand.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.brand, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRsiScoreDisplay() {
    final score = _result?.rsiScore;
    final quality = score != null ? rsiQuality(score) : null;

    return Column(
      children: [
        const Text(
          'REACTIVE STRENGTH INDEX',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          score != null ? score.toStringAsFixed(2) : '--',
          style: TextStyle(
            fontSize: 64,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
            fontFeatures: const [FontFeature.tabularFigures()],
            shadows: score != null
                ? [
                    Shadow(
                      color: AppColors.brand.withAlpha(128),
                      blurRadius: 16,
                    ),
                  ]
                : null,
          ),
        ),
        if (score != null)
          Text(
            '\u00b1 ${_result!.deltaRsi.toStringAsFixed(2)} error',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textTertiary,
            ),
          ),
        const SizedBox(height: 8),
        // Accent underline
        Container(
          width: 96,
          height: 4,
          decoration: BoxDecoration(
            color: score != null ? AppColors.brand : AppColors.borderLight,
            borderRadius: BorderRadius.circular(2),
            boxShadow: score != null
                ? [
                    BoxShadow(
                      color: AppColors.brand.withAlpha(100),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
        ),
        const SizedBox(height: 16),
        if (quality != null)
          Text(
            quality.label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: quality.color,
            ),
          ),
      ],
    );
  }

  Widget _buildActionButtons(bool hasResult) {
    if (!hasResult) {
      return SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: _recordJump,
          icon: const Icon(Icons.videocam_rounded),
          label: const Text('Record Drop Jump'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.brand,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _isSaving ? null : _saveTest,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.brand,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: AppColors.brand.withAlpha(128),
                ),
              ),
            ),
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.black,
                    ),
                  )
                : const Text('SAVE TEST RESULT'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _isSaving ? null : _discard,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              side: BorderSide(
                color: Colors.white.withAlpha(50),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: const Text('Discard'),
          ),
        ),
      ],
    );
  }
}
