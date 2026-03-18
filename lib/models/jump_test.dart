import 'package:isar/isar.dart';

part 'jump_test.g.dart';

@collection
class JumpTest {
  Id id = Isar.autoIncrement;

  @Index()
  late int athleteId;

  @Index()
  late String testType; // 'cmj_baseline', 'fatigue', 'rsi'

  late DateTime timestamp;

  late int takeoffFrame;
  late int landingFrame;
  late double fps;

  late double flightTimeMs;
  late double heightCm;
  late double deltaHCm;

  double? contactTimeMs; // RSI only
  double? rsiScore; // RSI only

  int? baselineSessionId;
  bool isOutlier = false;
}
