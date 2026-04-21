import 'package:isar/isar.dart';

part 'athlete.g.dart';

@collection
class Athlete {
  Id id = Isar.autoIncrement;

  late String name;
  double? weightKg;
  double? heightCm;
  String? avatarUrl;
  double? baselineCmjHeight; // in cm, null until first baseline is set
  DateTime? baselineDate; // when CMJ baseline was last set
  double? baselineRsi; // latest RSI score
  double? latestAsymmetryPct; // signed: positive = right stronger, negative = left stronger
  String? asymmetryStrongerLeg; // 'left' | 'right'
  DateTime? asymmetryDate;
  int sortOrder = 0;

  // Calculates Peak Power using Sayers Equation: (60.7 * jumpHeight_cm) + (45.3 * weight_kg) - 2055
  double? getPeakPower(double jumpHeightCm) {
    if (weightKg == null) return null;
    final power = (60.7 * jumpHeightCm) + (45.3 * weightKg!) - 2055;
    return power > 0 ? power : 0;
  }

  // Calculates Relative Power (W/kg) = Peak Power / weight_kg
  double? getRelativePower(double jumpHeightCm) {
    final peak = getPeakPower(jumpHeightCm);
    return peak != null ? peak / weightKg! : null;
  }
}
