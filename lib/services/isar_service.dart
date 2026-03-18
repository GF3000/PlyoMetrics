import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/athlete.dart';
import '../models/athlete_group.dart';

class IsarService {
  late final Isar _db;

  IsarService._();
  static final IsarService _instance = IsarService._();
  static IsarService get instance => _instance;

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    final dir = await getApplicationSupportDirectory();
    _db = await Isar.open(
      [AthleteSchema, AthleteGroupSchema],
      directory: dir.path,
    );
    _initialized = true;
  }

  Isar get db => _db;

  // ── Group CRUD ──

  Stream<List<AthleteGroup>> watchGroups() {
    return _db.athleteGroups.where().watch(fireImmediately: true);
  }

  Future<List<AthleteGroup>> getAllGroups() {
    return _db.athleteGroups.where().findAll();
  }

  Future<AthleteGroup> addGroup(String name) async {
    final group = AthleteGroup()..name = name;
    await _db.writeTxn(() async {
      await _db.athleteGroups.put(group);
    });
    return group;
  }

  Future<void> deleteGroup(int groupId) async {
    await _db.writeTxn(() async {
      await _db.athleteGroups.delete(groupId);
    });
  }

  // ── Athlete CRUD ──

  Future<Athlete> addAthlete({
    required String name,
    required double weightKg,
    required AthleteGroup group,
  }) async {
    final athlete = Athlete()
      ..name = name
      ..weightKg = weightKg;

    await _db.writeTxn(() async {
      await _db.athletes.put(athlete);
      group.athletes.add(athlete);
      await group.athletes.save();
    });
    return athlete;
  }

  Future<void> deleteAthlete(Athlete athlete) async {
    await _db.writeTxn(() async {
      await _db.athletes.delete(athlete.id);
    });
  }

  Future<List<Athlete>> getAthletesForGroup(AthleteGroup group) async {
    await group.athletes.load();
    return group.athletes.toList();
  }
}
