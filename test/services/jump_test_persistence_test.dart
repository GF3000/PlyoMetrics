import 'dart:io';

import 'package:plyometrics/models/jump_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

void main() {
  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  test('persists unified session and presentation timestamps', () async {
    final directory = await Directory.systemTemp.createTemp(
      'plyometrics_isar_test_',
    );
    final isar = await Isar.open(
      [JumpTestSchema],
      directory: directory.path,
      name: 'jump_test_contract',
    );

    try {
      final test = JumpTest()
        ..athleteId = 7
        ..testType = 'rsi'
        ..timestamp = DateTime.utc(2026, 1, 1)
        ..takeoffFrame = 20
        ..landingFrame = 50
        ..fps = 120
        ..flightTimeMs = 250
        ..heightCm = 7.664
        ..deltaHCm = 0.5
        ..sessionId = 1234
        ..landing1TimeSeconds = 1.0
        ..takeoffTimeSeconds = 1.15
        ..landingTimeSeconds = 1.4;

      await isar.writeTxn(() => isar.jumpTests.put(test));
      final stored = await isar.jumpTests.get(test.id);

      expect(stored, isNotNull);
      expect(stored!.sessionId, 1234);
      expect(stored.landing1TimeSeconds, 1.0);
      expect(stored.takeoffTimeSeconds, 1.15);
      expect(stored.landingTimeSeconds, 1.4);
    } finally {
      await isar.close(deleteFromDisk: true);
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }
    }
  });
}
