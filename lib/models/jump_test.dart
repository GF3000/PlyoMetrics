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

  int? takeoffFrame;
  int? landingFrame;
  double? fps;

  late double flightTimeMs;
  late double heightCm;
  late double deltaHCm;

  double? contactTimeMs; // RSI only
  double? rsiScore; // RSI only

  double? baselineAtTest; // baseline height at time of fatigue test

  /// Unified identifier shared by every trial captured in one test session.
  int? sessionId;
  bool isSummary = true;
  bool isOutlier = false;

  double? deltaRsi; // RSI: margin of error (±1 frame)

  double? dropHeightCm; // RSI: drop height in cm
  int? landing1Frame; // RSI: first ground contact frame
  double? landing1TimeSeconds;
  double? takeoffTimeSeconds;
  double? landingTimeSeconds;

  String? leg; // asymmetry: 'left' | 'right'
}
