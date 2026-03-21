import 'package:isar/isar.dart';

part 'athlete.g.dart';

@collection
class Athlete {
  Id id = Isar.autoIncrement;

  late String name;
  double? weightKg;
  String? avatarUrl;
  double? baselineCmjHeight; // in cm, null until first baseline is set
  DateTime? baselineDate; // when CMJ baseline was last set
  double? baselineRsi; // latest RSI score
  int sortOrder = 0;
}
