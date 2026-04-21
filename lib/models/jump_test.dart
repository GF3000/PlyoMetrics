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

  double? baselineAtTest; // baseline height at time of fatigue test

  int? baselineSessionId;
  bool isOutlier = false;

  double? deltaRsi; // RSI: margin of error (±1 frame)

  double? dropHeightCm; // RSI: drop height in cm
  int? landing1Frame; // RSI: first ground contact frame

  String? leg; // asymmetry: 'left' | 'right'
  int? asymmetrySessionId; // links the left+right pair for one asymmetry session
}
