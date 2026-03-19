import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/athlete.dart';
import '../models/athlete_group.dart';
import '../models/jump_test.dart';

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
      [AthleteSchema, AthleteGroupSchema, JumpTestSchema],
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

  Future<AthleteGroup> updateGroup(AthleteGroup group, String newName) async {
    await _db.writeTxn(() async {
      group.name = newName;
      await _db.athleteGroups.put(group);
    });
    return group;
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

  Future<Athlete> updateAthlete(Athlete athlete, {String? name, double? weightKg}) async {
    await _db.writeTxn(() async {
      if (name != null) athlete.name = name;
      if (weightKg != null) athlete.weightKg = weightKg;
      await _db.athletes.put(athlete);
    });
    return athlete;
  }

  Future<List<Athlete>> getAthletesForGroup(AthleteGroup group) async {
    await group.athletes.load();
    final list = group.athletes.toList();
    list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return list;
  }

  Future<void> reorderAthletes(List<Athlete> athletes) async {
    await _db.writeTxn(() async {
      for (int i = 0; i < athletes.length; i++) {
        athletes[i].sortOrder = i;
      }
      await _db.athletes.putAll(athletes);
    });
  }

  // ── JumpTest CRUD ──

  Future<void> saveJumpTests(List<JumpTest> tests) async {
    await _db.writeTxn(() async {
      await _db.jumpTests.putAll(tests);
    });
  }

  Future<void> updateAthleteBaseline(int athleteId, double heightCm) async {
    await _db.writeTxn(() async {
      final athlete = await _db.athletes.get(athleteId);
      if (athlete != null) {
        athlete.baselineCmjHeight = heightCm;
        await _db.athletes.put(athlete);
      }
    });
  }

  Future<void> deleteJumpTest(int testId) async {
    await _db.writeTxn(() async {
      await _db.jumpTests.delete(testId);
    });
  }

  Future<List<JumpTest>> getJumpTestsForAthlete(
    int athleteId,
    String testType,
  ) {
    return _db.jumpTests
        .filter()
        .athleteIdEqualTo(athleteId)
        .testTypeEqualTo(testType)
        .sortByTimestampDesc()
        .findAll();
  }
}
