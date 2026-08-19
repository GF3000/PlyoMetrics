import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:plyometrics/models/athlete.dart';
import 'package:plyometrics/models/athlete_group.dart';
import 'package:plyometrics/models/jump_test.dart';
import 'package:plyometrics/services/backup_service.dart';
import 'package:plyometrics/services/isar_service.dart';

void main() {
  late Directory directory;
  late Isar isar;
  late IsarService service;
  late BackupService backup;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('plyometrics_backup_');
    isar = await Isar.open(
      [AthleteSchema, AthleteGroupSchema, JumpTestSchema],
      directory: directory.path,
      name: 'backup_${DateTime.now().microsecondsSinceEpoch}',
    );
    service = IsarService.withDatabase(isar);
    backup = BackupService(service);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  });

  Future<Athlete> seedAthlete(String groupName, String athleteName) async {
    final group = await service.addGroup(groupName);
    return service.addAthlete(name: athleteName, weightKg: 70, group: group);
  }

  test('exports every group with athletes, summaries and raw trials', () async {
    final athlete = await seedAthlete('U18', 'Ana');
    await service.saveJumpTests([
      _jumpTest(athleteId: athlete.id, sessionId: 5, isSummary: false),
      _jumpTest(athleteId: athlete.id, sessionId: 5, isSummary: true),
    ]);

    final json = jsonDecode(await backup.exportToJson()) as Map<String, Object?>;

    expect(json['schemaVersion'], BackupService.schemaVersion);
    expect(json['scope'], 'all');
    expect((json['groups']! as List).single['name'], 'U18');
    expect((json['athletes']! as List).single['name'], 'Ana');
    expect((json['jumpTests']! as List).length, 2);
  });

  test('exports only the selected groups', () async {
    final first = await seedAthlete('U18', 'Ana');
    await seedAthlete('First Team', 'Bea');
    await service.saveJumpTests([
      _jumpTest(athleteId: first.id, sessionId: 1, isSummary: true),
    ]);

    final groups = await service.getAllGroups();
    final selected = groups.firstWhere((group) => group.name == 'First Team');
    final json =
        jsonDecode(await backup.exportToJson(groupIds: {selected.id}))
            as Map<String, Object?>;

    expect(json['scope'], 'selection');
    expect((json['groups']! as List).single['name'], 'First Team');
    expect((json['athletes']! as List).single['name'], 'Bea');
    expect(json['jumpTests'], isEmpty);
  });

  test('round trips a backup into a clean database', () async {
    final athlete = await seedAthlete('U18', 'Ana');
    await service.saveJumpTests([
      _jumpTest(
        athleteId: athlete.id,
        sessionId: 7,
        isSummary: false,
        heightCm: 31,
      ),
      _jumpTest(
        athleteId: athlete.id,
        sessionId: 7,
        isSummary: true,
        heightCm: 31,
        isOutlier: true,
      ),
    ]);
    final exported = await backup.exportToJson();

    // Wipe everything and restore.
    await isar.writeTxn(() => isar.clear());

    final result = await backup.import(
      backup.parse(exported),
      mergeIntoExistingGroups: true,
    );

    expect(result.groupsCreated, 1);
    expect(result.athletesImported, 1);
    expect(result.jumpTestsImported, 2);

    final groups = await service.getGroupsWithAthletes();
    expect(groups.single.name, 'U18');
    final restored = groups.single.athletes.single;
    expect(restored.name, 'Ana');
    expect(restored.weightKg, 70);

    final tests = await service.getAllJumpTestsForAthletes([restored.id]);
    expect(tests, hasLength(2));
    expect(tests.every((test) => test.athleteId == restored.id), isTrue);
    expect(tests.map((test) => test.sessionId).toSet(), hasLength(1));
    expect(tests.where((test) => test.isSummary).single.isOutlier, isTrue);
    expect(tests.where((test) => !test.isSummary), hasLength(1));
  });

  test('merges into an existing group and offsets session ids', () async {
    final athlete = await seedAthlete('U18', 'Ana');
    await service.saveJumpTests([
      _jumpTest(athleteId: athlete.id, sessionId: 3, isSummary: true),
    ]);
    final exported = await backup.exportToJson();

    final result = await backup.import(
      backup.parse(exported),
      mergeIntoExistingGroups: true,
    );

    expect(result.groupsCreated, 0);
    expect(result.groupsMerged, 1);
    final groups = await service.getGroupsWithAthletes();
    expect(groups, hasLength(1));
    expect(groups.single.athletes, hasLength(2));

    final sessionIds = (await isar.jumpTests.where().findAll())
        .map((test) => test.sessionId)
        .toSet();
    expect(sessionIds, hasLength(2));
  });

  test('creates a suffixed group when merging is declined', () async {
    await seedAthlete('U18', 'Ana');
    final exported = await backup.exportToJson();

    await backup.import(backup.parse(exported), mergeIntoExistingGroups: false);

    final names = (await service.getAllGroups()).map((g) => g.name).toSet();
    expect(names, {'U18', 'U18 (2)'});
  });

  test('imports an athlete shared by two groups only once', () async {
    final group = await service.addGroup('U18');
    final other = await service.addGroup('First Team');
    final athlete = await service.addAthlete(name: 'Ana', group: group);
    await isar.writeTxn(() async {
      other.athletes.add(athlete);
      await other.athletes.save();
    });

    final exported = await backup.exportToJson();
    await isar.writeTxn(() => isar.clear());
    final result = await backup.import(
      backup.parse(exported),
      mergeIntoExistingGroups: true,
    );

    expect(result.athletesImported, 1);
    expect(await isar.athletes.count(), 1);
    final groups = await service.getGroupsWithAthletes();
    expect(groups, hasLength(2));
    expect(groups.every((g) => g.athletes.length == 1), isTrue);
  });

  test('rejects malformed content', () {
    expect(
      () => backup.parse('not json'),
      throwsA(
        isA<BackupFormatException>().having(
          (e) => e.reason,
          'reason',
          BackupFormatError.malformed,
        ),
      ),
    );
  });

  test('rejects newer schema versions', () {
    final payload = jsonEncode({
      'schemaVersion': BackupService.schemaVersion + 1,
      'groups': [],
      'athletes': [],
      'jumpTests': [],
    });

    expect(
      () => backup.parse(payload),
      throwsA(
        isA<BackupFormatException>().having(
          (e) => e.reason,
          'reason',
          BackupFormatError.unsupportedVersion,
        ),
      ),
    );
  });

  test('rejects unknown test types', () {
    final payload = jsonEncode({
      'schemaVersion': BackupService.schemaVersion,
      'groups': [
        {'name': 'U18', 'athleteIds': [1]},
      ],
      'athletes': [
        {'id': 1, 'name': 'Ana'},
      ],
      'jumpTests': [
        {
          'athleteId': 1,
          'testType': 'unknown',
          'timestamp': '2026-01-01T00:00:00.000Z',
        },
      ],
    });

    expect(
      () => backup.parse(payload),
      throwsA(
        isA<BackupFormatException>().having(
          (e) => e.reason,
          'reason',
          BackupFormatError.invalidContent,
        ),
      ),
    );
  });

  test('drops jumps whose athlete is missing from the backup', () {
    final payload = jsonEncode({
      'schemaVersion': BackupService.schemaVersion,
      'groups': [
        {'name': 'U18', 'athleteIds': [1, 99]},
      ],
      'athletes': [
        {'id': 1, 'name': 'Ana'},
      ],
      'jumpTests': [
        {
          'athleteId': 99,
          'testType': 'rsi',
          'timestamp': '2026-01-01T00:00:00.000Z',
        },
      ],
    });

    final data = backup.parse(payload);

    expect(data.athleteCount, 1);
    expect(data.jumpTestCount, 0);
    expect(data.groups['U18'], [1]);
  });
}

JumpTest _jumpTest({
  required int athleteId,
  required int sessionId,
  required bool isSummary,
  double heightCm = 30,
  bool isOutlier = false,
  String testType = 'cmj_baseline',
}) {
  return JumpTest()
    ..athleteId = athleteId
    ..testType = testType
    ..timestamp = DateTime.utc(2026, 1, 1)
    ..flightTimeMs = 500
    ..heightCm = heightCm
    ..deltaHCm = 0.5
    ..fps = 120
    ..takeoffFrame = 10
    ..landingFrame = 70
    ..sessionId = sessionId
    ..isSummary = isSummary
    ..isOutlier = isOutlier;
}
