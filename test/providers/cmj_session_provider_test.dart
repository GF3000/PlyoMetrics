import 'package:plyometrics/models/athlete.dart';
import 'package:plyometrics/providers/cmj_session_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CmjSessionNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('allows an intentional one-jump baseline', () {
      final athlete = Athlete()
        ..id = 1
        ..name = 'Athlete';
      final notifier = container.read(cmjSessionProvider.notifier);

      notifier.initWithAthletes([athlete]);
      notifier.addJump(
        const JumpResult(
          takeoffFrame: 10,
          landingFrame: 40,
          fps: 120,
          flightTimeMs: 250,
          heightCm: 7.664,
          deltaHCm: 0.5,
          videoPath: 'jump.mp4',
        ),
      );

      final state = container.read(cmjSessionProvider);
      expect(state.canSave, isTrue);
      expect(state.activeSession?.validJumpCount, 1);
      expect(state.averageHeightCm, closeTo(7.664, 0.001));
    });

    test('does not allow an empty baseline', () {
      final athlete = Athlete()
        ..id = 1
        ..name = 'Athlete';

      container.read(cmjSessionProvider.notifier).initWithAthletes([athlete]);

      expect(container.read(cmjSessionProvider).canSave, isFalse);
    });
  });
}
