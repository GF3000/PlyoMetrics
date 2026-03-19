import 'package:isar/isar.dart';

part 'athlete.g.dart';

@collection
class Athlete {
  Id id = Isar.autoIncrement;

  late String name;
  late double weightKg;
  String? avatarUrl;
  double? baselineCmjHeight; // in cm, null until first baseline is set
  int sortOrder = 0;
}
