import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/athlete.dart';
import '../models/athlete_group.dart';
import '../models/jump_test.dart';

class IsarService {
  late final Isar _db;

  IsarService._();
  IsarService.withDatabase(Isar database) : _db = database, _initialized = true;

  static final IsarService _instance = IsarService._();
  static IsarService get instance => _instance;

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    final dir = await getApplicationSupportDirectory();
    _db = await Isar.open([
      AthleteSchema,
      AthleteGroupSchema,
      JumpTestSchema,
    ], directory: dir.path);
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
    final group = await _db.athleteGroups.get(groupId);
    if (group == null) return;
    await group.athletes.load();
    final athleteIds = group.athletes.map((athlete) => athlete.id).toList();

    await _db.writeTxn(() async {
      for (final athleteId in athleteIds) {
        final tests = await _db.jumpTests
            .filter()
            .athleteIdEqualTo(athleteId)
            .findAll();
        await _db.jumpTests.deleteAll(tests.map((test) => test.id).toList());
      }
      await _db.athletes.deleteAll(athleteIds);
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
      final tests = await _db.jumpTests
          .filter()
          .athleteIdEqualTo(athlete.id)
          .findAll();
      await _db.jumpTests.deleteAll(tests.map((test) => test.id).toList());
      await _db.athletes.delete(athlete.id);
    });
  }

  Future<Athlete> updateAthlete(
    Athlete athlete, {
    String? name,
    double? weightKg,
    double? heightCm,
    bool clearWeight = false,
    bool clearHeight = false,
  }) async {
    await _db.writeTxn(() async {
      if (name != null) athlete.name = name;
      if (clearWeight) {
        athlete.weightKg = null;
      } else if (weightKg != null) {
        athlete.weightKg = weightKg;
      }
      if (clearHeight) {
        athlete.heightCm = null;
      } else if (heightCm != null) {
        athlete.heightCm = heightCm;
      }
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

  Future<Athlete?> saveCmjBaselineSession({
    required List<JumpTest> tests,
    required int athleteId,
    required double heightCm,
    required DateTime baselineDate,
  }) async {
    Athlete? updated;
    await _db.writeTxn(() async {
      await _db.jumpTests.putAll(tests);
      final athlete = await _db.athletes.get(athleteId);
      if (athlete == null) return;
      athlete
        ..baselineCmjHeight = heightCm
        ..baselineDate = baselineDate;
      await _db.athletes.put(athlete);
      updated = athlete;
    });
    return updated;
  }

  Future<Athlete?> saveRsiSession({
    required List<JumpTest> tests,
    required int athleteId,
    required double rsiScore,
  }) async {
    Athlete? updated;
    await _db.writeTxn(() async {
      await _db.jumpTests.putAll(tests);
      final athlete = await _db.athletes.get(athleteId);
      if (athlete == null) return;
      athlete.baselineRsi = rsiScore;
      await _db.athletes.put(athlete);
      updated = athlete;
    });
    return updated;
  }

  Future<Athlete?> saveAsymmetrySession({
    required List<JumpTest> tests,
    required int athleteId,
    required double asymmetryPct,
    required String strongerLeg,
    required DateTime timestamp,
  }) async {
    Athlete? updated;
    await _db.writeTxn(() async {
      await _db.jumpTests.putAll(tests);
      final athlete = await _db.athletes.get(athleteId);
      if (athlete == null) return;
      athlete
        ..latestAsymmetryPct = asymmetryPct
        ..asymmetryStrongerLeg = strongerLeg
        ..asymmetryDate = timestamp;
      await _db.athletes.put(athlete);
      updated = athlete;
    });
    return updated;
  }

  Future<Athlete?> saveFatiguePersonalBest({
    required List<JumpTest> tests,
    required int athleteId,
    required double baselineHeightCm,
    required DateTime timestamp,
  }) async {
    Athlete? updated;
    await _db.writeTxn(() async {
      await _db.jumpTests.putAll(tests);
      final athlete = await _db.athletes.get(athleteId);
      if (athlete == null) return;
      athlete
        ..baselineCmjHeight = baselineHeightCm
        ..baselineDate = timestamp;
      await _db.athletes.put(athlete);
      updated = athlete;
    });
    return updated;
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

  Future<void> updateAthleteAsymmetry(
    int athleteId,
    double asymmetryPct,
    String strongerLeg,
  ) async {
    await _db.writeTxn(() async {
      final athlete = await _db.athletes.get(athleteId);
      if (athlete != null) {
        athlete.latestAsymmetryPct = asymmetryPct;
        athlete.asymmetryStrongerLeg = strongerLeg;
        athlete.asymmetryDate = DateTime.now();
        await _db.athletes.put(athlete);
      }
    });
  }

  Future<List<JumpTest>> getAsymmetryTestsForAthlete(int athleteId) {
    return _db.jumpTests
        .filter()
        .athleteIdEqualTo(athleteId)
        .testTypeEqualTo('asymmetry')
        .isSummaryEqualTo(true)
        .sortByTimestampDesc()
        .findAll();
  }

  Future<Athlete?> deleteJumpTest(int testId) async {
    Athlete? updatedAthlete;
    await _db.writeTxn(() async {
      final test = await _db.jumpTests.get(testId);
      if (test == null) return;

      final athleteId = test.athleteId;
      if (test.sessionId == null) {
        await _db.jumpTests.delete(testId);
      } else {
        final sessionTests = await _db.jumpTests
            .filter()
            .athleteIdEqualTo(athleteId)
            .sessionIdEqualTo(test.sessionId!)
            .findAll();
        await _db.jumpTests.deleteAll(sessionTests.map((t) => t.id).toList());
      }

      // Recalculate baseline from remaining jumps
      final remaining = await _db.jumpTests
          .filter()
          .athleteIdEqualTo(athleteId)
          .isSummaryEqualTo(true)
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
          cmjTests.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          final latest = cmjTests.first;
          athlete.baselineCmjHeight = latest.heightCm;
          athlete.baselineDate = latest.timestamp;
        }

        // Recalculate RSI baseline
        final rsiTests = remaining.where((t) => t.testType == 'rsi').toList();
        if (rsiTests.isEmpty) {
          athlete.baselineRsi = null;
        } else {
          rsiTests.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          athlete.baselineRsi = rsiTests.first.rsiScore;
        }

        // Recalculate asymmetry from remaining paired tests
        final asymmetryTests = remaining
            .where((t) => t.testType == 'asymmetry')
            .toList();
        if (asymmetryTests.isEmpty) {
          athlete.latestAsymmetryPct = null;
          athlete.asymmetryStrongerLeg = null;
          athlete.asymmetryDate = null;
        } else {
          asymmetryTests.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          final sessionIds = asymmetryTests
              .map((t) => t.sessionId ?? t.id)
              .toSet();
          JumpTest? latestLeft;
          JumpTest? latestRight;
          for (final sessionId in sessionIds) {
            final pair = asymmetryTests
                .where((t) => (t.sessionId ?? t.id) == sessionId)
                .toList();
            final left = pair.where((t) => t.leg == 'left').toList();
            final right = pair.where((t) => t.leg == 'right').toList();
            if (left.isNotEmpty && right.isNotEmpty) {
              latestLeft = left.first;
              latestRight = right.first;
              break;
            }
          }

          if (latestLeft == null || latestRight == null) {
            athlete.latestAsymmetryPct = null;
            athlete.asymmetryStrongerLeg = null;
            athlete.asymmetryDate = null;
          } else {
            final leftH = latestLeft.heightCm;
            final rightH = latestRight.heightCm;
            final maxH = leftH > rightH ? leftH : rightH;
            athlete.latestAsymmetryPct = maxH > 0
                ? (rightH - leftH) / maxH * 100
                : 0;
            athlete.asymmetryStrongerLeg = rightH >= leftH ? 'right' : 'left';
            athlete.asymmetryDate = latestLeft.timestamp;
          }
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
        .isSummaryEqualTo(true)
        .sortByTimestampDesc()
        .findAll();
  }

  Future<List<JumpTest>> getSummaryTestsForAthletes(
    Iterable<int> athleteIds, {
    String? testType,
  }) async {
    final ids = athleteIds.toSet();
    if (ids.isEmpty) return [];
    final summaries = await _db.jumpTests
        .filter()
        .isSummaryEqualTo(true)
        .findAll();
    return summaries
        .where(
          (test) =>
              ids.contains(test.athleteId) &&
              (testType == null || test.testType == testType),
        )
        .toList();
  }

  Future<JumpTest?> getLatestJumpTest(int athleteId, String testType) {
    return _db.jumpTests
        .filter()
        .athleteIdEqualTo(athleteId)
        .testTypeEqualTo(testType)
        .isSummaryEqualTo(true)
        .sortByTimestampDesc()
        .findFirst();
  }
}
