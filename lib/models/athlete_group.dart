import 'package:isar/isar.dart';
import 'athlete.dart';

part 'athlete_group.g.dart';

@collection
class AthleteGroup {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String name;

  final athletes = IsarLinks<Athlete>();
}
