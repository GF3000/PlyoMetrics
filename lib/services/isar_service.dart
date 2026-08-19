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

  /// Every jump test (summaries *and* raw trials) for the given athletes.
  Future<List<JumpTest>> getAllJumpTestsForAthletes(
    Iterable<int> athleteIds,
  ) async {
    final ids = athleteIds.toSet();
    if (ids.isEmpty) return [];
    final tests = <JumpTest>[];
    for (final athleteId in ids) {
      tests.addAll(
        await _db.jumpTests.filter().athleteIdEqualTo(athleteId).findAll(),
      );
    }
    return tests..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  /// All groups with their athlete links already loaded.
  Future<List<AthleteGroup>> getGroupsWithAthletes() async {
    final groups = await _db.athleteGroups.where().findAll();
    for (final group in groups) {
      await group.athletes.load();
    }
    return groups;
  }

  /// Imports a backup atomically: creates groups, athletes and jump tests with
  /// freshly assigned identifiers so nothing collides with existing data.
  ///
  /// [groups] maps a group name to the list of local athlete ids it contains.
  /// [athletes] maps a local athlete id to the (unsaved) athlete instance.
  /// [jumpTests] maps a local athlete id to that athlete's jump tests.
  /// When [mergeIntoExistingGroups] is true, athletes are appended to a group
  /// with the same name if it already exists; otherwise a new group is created
  /// with a numeric suffix.
  Future<ImportResult> importBackup({
    required Map<String, List<int>> groups,
    required Map<int, Athlete> athletes,
    required Map<int, List<JumpTest>> jumpTests,
    required bool mergeIntoExistingGroups,
  }) async {
    var groupsCreated = 0;
    var groupsMerged = 0;
    var athletesImported = 0;
    var jumpTestsImported = 0;

    await _db.writeTxn(() async {
      final existingGroups = await _db.athleteGroups.where().findAll();
      final existingNames = existingGroups.map((g) => g.name).toSet();

      // Offset applied to imported session ids so they never collide with the
      // sessions already stored on this device.
      final storedTests = await _db.jumpTests.where().findAll();
      var sessionOffset = 0;
      for (final test in storedTests) {
        final sessionId = test.sessionId;
        if (sessionId != null && sessionId > sessionOffset) {
          sessionOffset = sessionId;
        }
      }

      // Persist athletes first so their new ids are known.
      final athleteIdMap = <int, int>{};
      for (final entry in athletes.entries) {
        final athlete = entry.value..id = Isar.autoIncrement;
        await _db.athletes.put(athlete);
        athleteIdMap[entry.key] = athlete.id;
        athletesImported++;
      }

      for (final entry in groups.entries) {
        AthleteGroup? target;
        if (existingNames.contains(entry.key)) {
          if (mergeIntoExistingGroups) {
            target = existingGroups.firstWhere((g) => g.name == entry.key);
            await target.athletes.load();
            groupsMerged++;
          } else {
            var suffix = 2;
            var candidate = '${entry.key} ($suffix)';
            while (existingNames.contains(candidate)) {
              suffix++;
              candidate = '${entry.key} ($suffix)';
            }
            existingNames.add(candidate);
            target = AthleteGroup()..name = candidate;
            await _db.athleteGroups.put(target);
            groupsCreated++;
          }
        } else {
          existingNames.add(entry.key);
          target = AthleteGroup()..name = entry.key;
          await _db.athleteGroups.put(target);
          groupsCreated++;
        }

        for (final localAthleteId in entry.value) {
          final newId = athleteIdMap[localAthleteId];
          if (newId == null) continue;
          final athlete = await _db.athletes.get(newId);
          if (athlete == null) continue;
          target.athletes.add(athlete);
        }
        await target.athletes.save();
      }

      for (final entry in jumpTests.entries) {
        final newAthleteId = athleteIdMap[entry.key];
        if (newAthleteId == null) continue;
        final tests = <JumpTest>[];
        for (final test in entry.value) {
          test
            ..id = Isar.autoIncrement
            ..athleteId = newAthleteId;
          final sessionId = test.sessionId;
          if (sessionId != null) {
            test.sessionId = sessionId + sessionOffset;
          }
          tests.add(test);
        }
        await _db.jumpTests.putAll(tests);
        jumpTestsImported += tests.length;
      }
    });

    return ImportResult(
      groupsCreated: groupsCreated,
      groupsMerged: groupsMerged,
      athletesImported: athletesImported,
      jumpTestsImported: jumpTestsImported,
    );
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

/// Summary of a completed backup import.
class ImportResult {
  const ImportResult({
    required this.groupsCreated,
    required this.groupsMerged,
    required this.athletesImported,
    required this.jumpTestsImported,
  });

  final int groupsCreated;
  final int groupsMerged;
  final int athletesImported;
  final int jumpTestsImported;
}
