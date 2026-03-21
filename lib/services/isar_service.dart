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
    double? weightKg,
    double? heightCm,
    required AthleteGroup group,
  }) async {
    final athlete = Athlete()
      ..name = name
      ..weightKg = weightKg
      ..heightCm = heightCm;

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

  Future<Athlete> updateAthlete(Athlete athlete, {String? name, double? weightKg, double? heightCm}) async {
    await _db.writeTxn(() async {
      if (name != null) athlete.name = name;
      if (weightKg != null) athlete.weightKg = weightKg;
      if (heightCm != null) athlete.heightCm = heightCm;
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

  Future<void> updateAthleteBaseline(
    int athleteId,
    double heightCm, {
    DateTime? baselineDate,
  }) async {
    await _db.writeTxn(() async {
      final athlete = await _db.athletes.get(athleteId);
      if (athlete != null) {
        athlete.baselineCmjHeight = heightCm;
        if (baselineDate != null) {
          athlete.baselineDate = baselineDate;
        }
        await _db.athletes.put(athlete);
      }
    });
  }

  Future<void> updateAthleteRsi(int athleteId, double rsiScore) async {
    await _db.writeTxn(() async {
      final athlete = await _db.athletes.get(athleteId);
      if (athlete != null) {
        athlete.baselineRsi = rsiScore;
        await _db.athletes.put(athlete);
      }
    });
  }

  Future<Athlete?> deleteJumpTest(int testId) async {
    Athlete? updatedAthlete;
    await _db.writeTxn(() async {
      final test = await _db.jumpTests.get(testId);
      if (test == null) return;

      final athleteId = test.athleteId;
      await _db.jumpTests.delete(testId);

      // Recalculate baseline from remaining jumps
      final remaining = await _db.jumpTests
          .filter()
          .athleteIdEqualTo(athleteId)
          .findAll();

      final athlete = await _db.athletes.get(athleteId);
      if (athlete != null) {
        // Recalculate CMJ baseline height and date
        final cmjTests = remaining
            .where((t) => t.testType == 'cmj_baseline')
            .toList();
        if (cmjTests.isEmpty) {
          athlete.baselineCmjHeight = null;
          athlete.baselineDate = null;
        } else {
          athlete.baselineCmjHeight = cmjTests
              .map((t) => t.heightCm)
              .reduce((a, b) => a > b ? a : b);
          cmjTests.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          athlete.baselineDate = cmjTests.first.timestamp;
        }

        // Recalculate RSI baseline
        final rsiTests = remaining
            .where((t) => t.testType == 'rsi')
            .toList();
        if (rsiTests.isEmpty) {
          athlete.baselineRsi = null;
        } else {
          rsiTests.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          athlete.baselineRsi = rsiTests.first.rsiScore;
        }

        await _db.athletes.put(athlete);
        updatedAthlete = athlete;
      }
    });
    return updatedAthlete;
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

  Future<JumpTest?> getLatestJumpTest(int athleteId, String testType) {
    return _db.jumpTests
        .filter()
        .athleteIdEqualTo(athleteId)
        .testTypeEqualTo(testType)
        .sortByTimestampDesc()
        .findFirst();
  }
}
