import 'package:flutter_test/flutter_test.dart';
import 'package:plyometrics/models/athlete.dart';
import 'package:plyometrics/models/jump_test.dart';
import 'package:plyometrics/services/csv_export_service.dart';
import 'package:plyometrics/services/export_file_service.dart';

void main() {
  const service = CsvExportService();

  Athlete athlete({
    int id = 1,
    String name = 'Ana',
    double? baseline = 30,
    double? asymmetry,
  }) {
    return Athlete()
      ..id = id
      ..name = name
      ..weightKg = 70
      ..heightCm = 170
      ..baselineCmjHeight = baseline
      ..baselineDate = DateTime.utc(2026, 2, 1)
      ..baselineRsi = 1.5
      ..latestAsymmetryPct = asymmetry
      ..asymmetryStrongerLeg = asymmetry == null ? null : 'right'
      ..asymmetryDate = asymmetry == null ? null : DateTime.utc(2026, 3, 1);
  }

  JumpTest jump({
    int athleteId = 1,
    String testType = 'cmj_baseline',
    double heightCm = 30,
    DateTime? timestamp,
    bool isSummary = true,
    bool isOutlier = false,
    double? rsiScore,
  }) {
    return JumpTest()
      ..athleteId = athleteId
      ..testType = testType
      ..timestamp = timestamp ?? DateTime.utc(2026, 1, 1)
      ..flightTimeMs = 500
      ..heightCm = heightCm
      ..deltaHCm = 0.5
      ..fps = 120
      ..takeoffFrame = 10
      ..landingFrame = 70
      ..sessionId = 3
      ..isSummary = isSummary
      ..isOutlier = isOutlier
      ..rsiScore = rsiScore;
  }

  test('athlete export writes a header and one row per jump', () {
    final csv = service.athleteJumps(athlete(), [
      jump(),
      jump(isSummary: false),
    ]);
    final lines = csv.trim().split('\n');

    expect(
      lines.first.startsWith('Athlete,Date,Test Type,Session,Record'),
      isTrue,
    );
    expect(lines, hasLength(3));
    expect(
      lines.skip(1).where(
        (line) => line.startsWith(
          'Ana,2026-01-01T00:00:00.000Z,cmj_baseline,3,summary,no',
        ),
      ),
      hasLength(1),
    );
    expect(lines.skip(1).where((line) => line.contains(',trial,')), hasLength(1));
  });

  test('athlete export with no jumps only contains the header', () {
    final csv = service.athleteJumps(athlete(), []);

    expect(csv.trim().split('\n'), hasLength(1));
  });

  test('quotes values containing separators or quotes', () {
    final csv = service.athleteJumps(athlete(name: 'Smith, "Bo"'), [jump()]);

    expect(csv, contains('"Smith, ""Bo"""'));
  });

  test('group jump export prefixes group and athlete and skips strangers', () {
    final csv = service.groupJumps(
      groupName: 'U18',
      athletes: [athlete(), athlete(id: 2, name: 'Bea')],
      tests: [jump(), jump(athleteId: 2), jump(athleteId: 99)],
    );
    final lines = csv.trim().split('\n');

    expect(lines.first.startsWith('Group,Athlete,Date'), isTrue);
    expect(lines, hasLength(3));
    expect(lines[1].startsWith('U18,'), isTrue);
  });

  test('group marks export aggregates one row per athlete', () {
    final csv = service.groupMarks(
      groupName: 'U18',
      athletes: [athlete(asymmetry: -8)],
      tests: [
        jump(heightCm: 25, timestamp: DateTime.utc(2026, 1, 1)),
        jump(heightCm: 30, timestamp: DateTime.utc(2026, 2, 1)),
        jump(
          testType: 'rsi',
          rsiScore: 1.5,
          timestamp: DateTime.utc(2026, 2, 2),
        ),
        jump(testType: 'rsi', rsiScore: 2, timestamp: DateTime.utc(2026, 2, 3)),
      ],
    );
    final lines = csv.trim().split('\n');
    final values = lines[1].split(',');

    expect(lines, hasLength(2));
    expect(values[0], 'U18');
    expect(values[1], 'Ana');
    expect(values[4], '30.000'); // CMJ baseline
    expect(values[6], '30.000'); // best CMJ height
    expect(values[7], '20.000'); // improvement from 25 cm to 30 cm
    expect(values[8], '2.000'); // latest RSI
    expect(values[9], '2.000'); // best RSI
    expect(values[12], '-8.000'); // asymmetry
    expect(values[13], 'right');
  });

  test('group marks export leaves empty cells for missing metrics', () {
    final csv = service.groupMarks(
      groupName: 'U18',
      athletes: [athlete(baseline: null)],
      tests: const [],
    );
    final values = csv.trim().split('\n')[1].split(',');

    expect(values[4], '');
    expect(values[7], '');
    expect(values[13], '');
  });

  test('file names are sanitized and timestamped', () {
    final name = ExportFileService.fileName(
      'plyometrics_Ana Pérez/2_jumps',
      'csv',
      now: DateTime(2026, 3, 4, 5, 6),
    );

    expect(name, 'plyometrics_ana_p_rez_2_jumps_20260304_0506.csv');
  });
}
