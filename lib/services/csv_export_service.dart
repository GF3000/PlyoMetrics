import '../models/athlete.dart';
import '../models/jump_test.dart';

/// Builds CSV documents from athlete and jump data.
///
/// Headers are intentionally kept in English (not localized) so exported files
/// stay interoperable regardless of the app language. Numbers use a dot as the
/// decimal separator and dates are ISO-8601.
class CsvExportService {
  const CsvExportService();

  static const List<String> _jumpColumns = [
    'Date',
    'Test Type',
    'Session',
    'Record',
    'Outlier',
    'FPS',
    'Takeoff Frame',
    'First Landing Frame',
    'Landing Frame',
    'Flight Time (ms)',
    'Contact Time (ms)',
    'Height (cm)',
    'Height Margin (cm)',
    'RSI',
    'RSI Margin',
    'Drop Height (cm)',
    'Leg',
    'Baseline At Test (cm)',
  ];

  static const List<String> _markColumns = [
    'Group',
    'Athlete',
    'Weight (kg)',
    'Body Height (cm)',
    'CMJ Baseline (cm)',
    'CMJ Baseline Date',
    'Best CMJ Height (cm)',
    'CMJ Improvement (%)',
    'Latest RSI',
    'Best RSI',
    'Latest Contact Time (ms)',
    'Latest Flight Time (ms)',
    'Asymmetry (%)',
    'Stronger Leg',
    'Asymmetry Date',
  ];

  /// One row per jump of a single athlete.
  String athleteJumps(Athlete athlete, List<JumpTest> tests) {
    final rows = <List<String>>[
      ['Athlete', ..._jumpColumns],
    ];
    for (final test in _sorted(tests)) {
      rows.add([athlete.name, ..._jumpRow(test)]);
    }
    return _encode(rows);
  }

  /// One row per jump for every athlete of a group.
  String groupJumps({
    required String groupName,
    required List<Athlete> athletes,
    required List<JumpTest> tests,
  }) {
    final rows = <List<String>>[
      ['Group', 'Athlete', ..._jumpColumns],
    ];
    final byId = {for (final athlete in athletes) athlete.id: athlete};
    for (final test in _sorted(tests)) {
      final athlete = byId[test.athleteId];
      if (athlete == null) continue;
      rows.add([groupName, athlete.name, ..._jumpRow(test)]);
    }
    return _encode(rows);
  }

  /// One row per athlete with their aggregated marks.
  String groupMarks({
    required String groupName,
    required List<Athlete> athletes,
    required List<JumpTest> tests,
  }) {
    final rows = <List<String>>[_markColumns];
    for (final athlete in athletes) {
      final athleteTests = tests
          .where((test) => test.athleteId == athlete.id && test.isSummary)
          .toList();

      final cmj =
          athleteTests
              .where((test) => test.testType == 'cmj_baseline' && !test.isOutlier)
              .toList()
            ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
      final rsi =
          athleteTests.where((test) => test.testType == 'rsi').toList()
            ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

      final bestCmj = cmj.isEmpty
          ? null
          : cmj.map((t) => t.heightCm).reduce((a, b) => a > b ? a : b);
      double? improvement;
      if (cmj.length >= 2 &&
          athlete.baselineCmjHeight != null &&
          cmj.first.heightCm > 0) {
        improvement =
            ((athlete.baselineCmjHeight! - cmj.first.heightCm) /
                cmj.first.heightCm) *
            100;
      }
      final rsiScores = rsi
          .map((test) => test.rsiScore)
          .whereType<double>()
          .toList();
      final latestRsi = rsi.isEmpty ? null : rsi.last;

      rows.add([
        groupName,
        athlete.name,
        _number(athlete.weightKg),
        _number(athlete.heightCm),
        _number(athlete.baselineCmjHeight),
        _date(athlete.baselineDate),
        _number(bestCmj),
        _number(improvement),
        _number(latestRsi?.rsiScore ?? athlete.baselineRsi),
        _number(
          rsiScores.isEmpty ? null : rsiScores.reduce((a, b) => a > b ? a : b),
        ),
        _number(latestRsi?.contactTimeMs),
        _number(latestRsi?.flightTimeMs),
        _number(athlete.latestAsymmetryPct),
        athlete.asymmetryStrongerLeg ?? '',
        _date(athlete.asymmetryDate),
      ]);
    }
    return _encode(rows);
  }

  List<JumpTest> _sorted(List<JumpTest> tests) =>
      List<JumpTest>.from(tests)
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

  List<String> _jumpRow(JumpTest test) => [
    _date(test.timestamp),
    test.testType,
    test.sessionId?.toString() ?? '',
    test.isSummary ? 'summary' : 'trial',
    test.isOutlier ? 'yes' : 'no',
    _number(test.fps),
    test.takeoffFrame?.toString() ?? '',
    test.landing1Frame?.toString() ?? '',
    test.landingFrame?.toString() ?? '',
    _number(test.flightTimeMs),
    _number(test.contactTimeMs),
    _number(test.heightCm),
    _number(test.deltaHCm),
    _number(test.rsiScore),
    _number(test.deltaRsi),
    _number(test.dropHeightCm),
    test.leg ?? '',
    _number(test.baselineAtTest),
  ];

  String _number(double? value) {
    if (value == null) return '';
    return value.toStringAsFixed(3);
  }

  String _date(DateTime? value) {
    if (value == null) return '';
    return value.toUtc().toIso8601String();
  }

  String _encode(List<List<String>> rows) {
    final buffer = StringBuffer();
    for (final row in rows) {
      buffer.writeln(row.map(_escape).join(','));
    }
    return buffer.toString();
  }

  String _escape(String value) {
    if (value.contains(RegExp(r'[",\n\r]'))) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}
