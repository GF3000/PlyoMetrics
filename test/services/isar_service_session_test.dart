import 'dart:io';

import 'package:plyometrics/models/athlete.dart';
import 'package:plyometrics/models/athlete_group.dart';
import 'package:plyometrics/models/jump_test.dart';
import 'package:plyometrics/services/isar_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

void main() {
  late Directory directory;
  late Isar isar;
  late IsarService service;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    directory = await Directory.systemTemp.createTemp(
      'plyometrics_service_test_',
    );
    isar = await Isar.open(
      [AthleteSchema, AthleteGroupSchema, JumpTestSchema],
      directory: directory.path,
      name: 'service_${DateTime.now().microsecondsSinceEpoch}',
    );
    service = IsarService.withDatabase(isar);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  });

  test(
    'saves raw CMJ trials and summary with the athlete baseline atomically',
    () async {
      final athlete = Athlete()..name = 'Athlete';
      await isar.writeTxn(() => isar.athletes.put(athlete));
      final timestamp = DateTime.utc(2026, 1, 1);
      final raw =
          _jumpTest(
              athleteId: athlete.id,
              timestamp: timestamp,
              sessionId: 10,
              heightCm: 30,
              isSummary: false,
            )
            ..takeoffFrame = 10
            ..landingFrame = 40
            ..fps = 120;
      final summary = _jumpTest(
        athleteId: athlete.id,
        timestamp: timestamp,
        sessionId: 10,
        heightCm: 30,
        isSummary: true,
      );

      final updated = await service.saveCmjBaselineSession(
        tests: [raw, summary],
        athleteId: athlete.id,
        heightCm: 30,
        baselineDate: timestamp,
      );

      expect(updated?.baselineCmjHeight, 30);
      expect(updated?.baselineDate, timestamp);
      expect(await isar.jumpTests.count(), 2);
    },
  );

  test(
    'recalculation keeps the latest CMJ session instead of the maximum',
    () async {
      final athlete = Athlete()
        ..name = 'Athlete'
        ..baselineCmjHeight = 30
        ..baselineDate = DateTime.utc(2026, 2, 1);
      await isar.writeTxn(() => isar.athletes.put(athlete));

      final olderHigh = _jumpTest(
        athleteId: athlete.id,
        timestamp: DateTime.utc(2026, 1, 1),
        sessionId: 1,
        heightCm: 40,
        isSummary: true,
      );
      final latestLower = _jumpTest(
        athleteId: athlete.id,
        timestamp: DateTime.utc(2026, 2, 1),
        sessionId: 2,
        heightCm: 30,
        isSummary: true,
      );
      final fatigue = _jumpTest(
        athleteId: athlete.id,
        timestamp: DateTime.utc(2026, 2, 2),
        sessionId: 3,
        heightCm: 28,
        isSummary: true,
        testType: 'fatigue',
      )..baselineAtTest = 30;

      await isar.writeTxn(
        () => isar.jumpTests.putAll([olderHigh, latestLower, fatigue]),
      );

      final updated = await service.deleteJumpTest(fatigue.id);

      expect(updated?.baselineCmjHeight, 30);
      expect(
        updated?.baselineDate?.millisecondsSinceEpoch,
        DateTime.utc(2026, 2, 1).millisecondsSinceEpoch,
      );
    },
  );

  test('deleting a session summary removes its raw trials', () async {
    final athlete = Athlete()..name = 'Athlete';
    await isar.writeTxn(() => isar.athletes.put(athlete));
    final timestamp = DateTime.utc(2026, 1, 1);
    final raw = _jumpTest(
      athleteId: athlete.id,
      timestamp: timestamp,
      sessionId: 44,
      heightCm: 29,
      isSummary: false,
    );
    final summary = _jumpTest(
      athleteId: athlete.id,
      timestamp: timestamp,
      sessionId: 44,
      heightCm: 29,
      isSummary: true,
    );
    await isar.writeTxn(() => isar.jumpTests.putAll([raw, summary]));

    await service.deleteJumpTest(summary.id);

    final remaining = await isar.jumpTests
        .filter()
        .sessionIdEqualTo(44)
        .findAll();
    expect(remaining, isEmpty);
  });

  test('personal-best save refreshes the baseline date atomically', () async {
    final athlete = Athlete()
      ..name = 'Athlete'
      ..baselineCmjHeight = 25
      ..baselineDate = DateTime.utc(2025, 1, 1);
    await isar.writeTxn(() => isar.athletes.put(athlete));
    final timestamp = DateTime.utc(2026, 3, 1);
    final summary = _jumpTest(
      athleteId: athlete.id,
      timestamp: timestamp,
      sessionId: 80,
      heightCm: 32,
      isSummary: true,
    );

    final updated = await service.saveFatiguePersonalBest(
      tests: [summary],
      athleteId: athlete.id,
      baselineHeightCm: 32,
      timestamp: timestamp,
    );

    expect(updated?.baselineCmjHeight, 32);
    expect(
      updated?.baselineDate?.millisecondsSinceEpoch,
      timestamp.millisecondsSinceEpoch,
    );
  });

  test('deleting an athlete removes its jump records', () async {
    final athlete = Athlete()..name = 'Athlete';
    await isar.writeTxn(() => isar.athletes.put(athlete));
    final test = _jumpTest(
      athleteId: athlete.id,
      timestamp: DateTime.utc(2026, 1, 1),
      sessionId: 90,
      heightCm: 30,
      isSummary: true,
    );
    await isar.writeTxn(() => isar.jumpTests.put(test));

    await service.deleteAthlete(athlete);

    expect(await isar.athletes.get(athlete.id), isNull);
    expect(await isar.jumpTests.count(), 0);
  });

  test('deleting a group removes its athletes and jump records', () async {
    final athlete = Athlete()..name = 'Athlete';
    final group = AthleteGroup()..name = 'Group';
    await isar.writeTxn(() async {
      await isar.athletes.put(athlete);
      await isar.athleteGroups.put(group);
      group.athletes.add(athlete);
      await group.athletes.save();
    });
    final test = _jumpTest(
      athleteId: athlete.id,
      timestamp: DateTime.utc(2026, 1, 1),
      sessionId: 91,
      heightCm: 30,
      isSummary: true,
    );
    await isar.writeTxn(() => isar.jumpTests.put(test));

    await service.deleteGroup(group.id);

    expect(await isar.athleteGroups.get(group.id), isNull);
    expect(await isar.athletes.get(athlete.id), isNull);
    expect(await isar.jumpTests.count(), 0);
  });

  test('editing an athlete can clear optional measurements', () async {
    final athlete = Athlete()
      ..name = 'Athlete'
      ..weightKg = 80
      ..heightCm = 185;
    await isar.writeTxn(() => isar.athletes.put(athlete));

    final updated = await service.updateAthlete(
      athlete,
      clearWeight: true,
      clearHeight: true,
    );

    expect(updated.weightKg, isNull);
    expect(updated.heightCm, isNull);
  });

  test(
    'batch summary lookup excludes raw trials and unrelated athletes',
    () async {
      final athlete1 = Athlete()..name = 'One';
      final athlete2 = Athlete()..name = 'Two';
      final athlete3 = Athlete()..name = 'Three';
      await isar.writeTxn(
        () => isar.athletes.putAll([athlete1, athlete2, athlete3]),
      );
      final timestamp = DateTime.utc(2026, 1, 1);
      await isar.writeTxn(
        () => isar.jumpTests.putAll([
          _jumpTest(
            athleteId: athlete1.id,
            timestamp: timestamp,
            sessionId: 100,
            heightCm: 30,
            isSummary: true,
          ),
          _jumpTest(
            athleteId: athlete1.id,
            timestamp: timestamp,
            sessionId: 100,
            heightCm: 30,
            isSummary: false,
          ),
          _jumpTest(
            athleteId: athlete2.id,
            timestamp: timestamp,
            sessionId: 101,
            heightCm: 31,
            isSummary: true,
          ),
          _jumpTest(
            athleteId: athlete3.id,
            timestamp: timestamp,
            sessionId: 102,
            heightCm: 32,
            isSummary: true,
          ),
        ]),
      );

      final tests = await service.getSummaryTestsForAthletes([
        athlete1.id,
        athlete2.id,
      ], testType: 'cmj_baseline');

      expect(tests, hasLength(2));
      expect(tests.every((test) => test.isSummary), isTrue);
      expect(tests.map((test) => test.athleteId).toSet(), {
        athlete1.id,
        athlete2.id,
      });
    },
  );
}

JumpTest _jumpTest({
  required int athleteId,
  required DateTime timestamp,
  required int sessionId,
  required double heightCm,
  required bool isSummary,
  String testType = 'cmj_baseline',
}) {
  return JumpTest()
    ..athleteId = athleteId
    ..testType = testType
    ..timestamp = timestamp
    ..flightTimeMs = 500
    ..heightCm = heightCm
    ..deltaHCm = 0.5
    ..sessionId = sessionId
    ..isSummary = isSummary;
}
