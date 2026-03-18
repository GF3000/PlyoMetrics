import 'package:isar/isar.dart';

part 'athlete.g.dart';

@collection
class Athlete {
  Id id = Isar.autoIncrement;

  late String name;
  late double weightKg;
  String? avatarUrl;
}
