import 'dart:convert';

import '../models/athlete.dart';
import '../models/jump_test.dart';
import 'isar_service.dart';

/// Thrown when a backup file cannot be parsed or is not supported.
class BackupFormatException implements Exception {
  const BackupFormatException(this.reason);

  final BackupFormatError reason;

  @override
  String toString() => 'BackupFormatException(${reason.name})';
}

/// Machine readable reason of a backup parsing failure, resolved to a
/// localized message by the UI layer.
enum BackupFormatError {
  /// The file is not valid JSON or is not a JSON object.
  malformed,

  /// The file was produced by a newer, unsupported version of the app.
  unsupportedVersion,

  /// The JSON is well formed but required fields are missing or mistyped.
  invalidContent,
}

/// A parsed, validated backup ready to be written to the database.
class BackupData {
  const BackupData({
    required this.exportedAt,
    required this.groups,
    required this.athletes,
    required this.jumpTests,
  });

  /// When the backup was produced (UTC).
  final DateTime? exportedAt;

  /// Group name to the list of local athlete ids belonging to it.
  final Map<String, List<int>> groups;

  /// Local athlete id to the athlete instance (ids are not yet assigned).
  final Map<int, Athlete> athletes;

  /// Local athlete id to that athlete's jump tests.
  final Map<int, List<JumpTest>> jumpTests;

  int get groupCount => groups.length;
  int get athleteCount => athletes.length;
  int get jumpTestCount =>
      jumpTests.values.fold(0, (total, tests) => total + tests.length);
}

/// Serializes the whole app state to JSON and restores it back.
class BackupService {
  BackupService(this._isar);

  final IsarService _isar;

  /// Schema version of the files produced by this build.
  static const int schemaVersion = 1;

  static const Set<String> _knownTestTypes = {
    'cmj_baseline',
    'fatigue',
    'rsi',
    'asymmetry',
  };

  /// Builds a JSON backup. When [groupIds] is null every group is exported,
  /// otherwise only the selected ones (and their athletes and jumps).
  Future<String> exportToJson({Set<int>? groupIds}) async {
    final allGroups = await _isar.getGroupsWithAthletes();
    final groups = groupIds == null
        ? allGroups
        : allGroups.where((group) => groupIds.contains(group.id)).toList();

    // An athlete may belong to several groups: export it only once.
    final athletesById = <int, Athlete>{};
    final groupPayload = <Map<String, Object?>>[];
    for (final group in groups) {
      final memberIds = <int>[];
      for (final athlete in group.athletes) {
        athletesById[athlete.id] = athlete;
        memberIds.add(athlete.id);
      }
      groupPayload.add({'name': group.name, 'athleteIds': memberIds});
    }

    final tests = await _isar.getAllJumpTestsForAthletes(athletesById.keys);

    final payload = <String, Object?>{
      'schemaVersion': schemaVersion,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'scope': groupIds == null ? 'all' : 'selection',
      'groups': groupPayload,
      'athletes': athletesById.values.map(_athleteToJson).toList(),
      'jumpTests': tests.map(_jumpTestToJson).toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  /// Parses and validates a backup file.
  BackupData parse(String content) {
    Object? decoded;
    try {
      decoded = jsonDecode(content);
    } on FormatException {
      throw const BackupFormatException(BackupFormatError.malformed);
    }
    if (decoded is! Map<String, dynamic>) {
      throw const BackupFormatException(BackupFormatError.malformed);
    }

    final version = decoded['schemaVersion'];
    if (version is! int) {
      throw const BackupFormatException(BackupFormatError.invalidContent);
    }
    if (version > schemaVersion) {
      throw const BackupFormatException(BackupFormatError.unsupportedVersion);
    }

    final rawGroups = decoded['groups'];
    final rawAthletes = decoded['athletes'];
    final rawTests = decoded['jumpTests'];
    if (rawGroups is! List || rawAthletes is! List || rawTests is! List) {
      throw const BackupFormatException(BackupFormatError.invalidContent);
    }

    final athletes = <int, Athlete>{};
    for (final entry in rawAthletes) {
      if (entry is! Map<String, dynamic>) {
        throw const BackupFormatException(BackupFormatError.invalidContent);
      }
      final id = _requireInt(entry['id']);
      athletes[id] = _athleteFromJson(entry);
    }

    final groups = <String, List<int>>{};
    for (final entry in rawGroups) {
      if (entry is! Map<String, dynamic>) {
        throw const BackupFormatException(BackupFormatError.invalidContent);
      }
      final name = entry['name'];
      final ids = entry['athleteIds'];
      if (name is! String || name.isEmpty || ids is! List) {
        throw const BackupFormatException(BackupFormatError.invalidContent);
      }
      final members = <int>[];
      for (final id in ids) {
        final athleteId = _requireInt(id);
        // Ignore references to athletes missing from the file.
        if (athletes.containsKey(athleteId)) members.add(athleteId);
      }
      groups.putIfAbsent(name, () => <int>[]).addAll(members);
    }

    final jumpTests = <int, List<JumpTest>>{};
    for (final entry in rawTests) {
      if (entry is! Map<String, dynamic>) {
        throw const BackupFormatException(BackupFormatError.invalidContent);
      }
      final athleteId = _requireInt(entry['athleteId']);
      // Drop orphan jumps whose athlete is not part of the backup.
      if (!athletes.containsKey(athleteId)) continue;
      jumpTests
          .putIfAbsent(athleteId, () => <JumpTest>[])
          .add(_jumpTestFromJson(entry));
    }

    return BackupData(
      exportedAt: _optionalDate(decoded['exportedAt']),
      groups: groups,
      athletes: athletes,
      jumpTests: jumpTests,
    );
  }

  /// Writes a parsed backup into the database.
  Future<ImportResult> import(
    BackupData data, {
    required bool mergeIntoExistingGroups,
  }) {
    return _isar.importBackup(
      groups: data.groups,
      athletes: data.athletes,
      jumpTests: data.jumpTests,
      mergeIntoExistingGroups: mergeIntoExistingGroups,
    );
  }

  // ── Serialization helpers ──

  Map<String, Object?> _athleteToJson(Athlete athlete) => {
    'id': athlete.id,
    'name': athlete.name,
    'weightKg': athlete.weightKg,
    'heightCm': athlete.heightCm,
    'avatarUrl': athlete.avatarUrl,
    'baselineCmjHeight': athlete.baselineCmjHeight,
    'baselineDate': athlete.baselineDate?.toUtc().toIso8601String(),
    'baselineRsi': athlete.baselineRsi,
    'latestAsymmetryPct': athlete.latestAsymmetryPct,
    'asymmetryStrongerLeg': athlete.asymmetryStrongerLeg,
    'asymmetryDate': athlete.asymmetryDate?.toUtc().toIso8601String(),
    'sortOrder': athlete.sortOrder,
  };

  Athlete _athleteFromJson(Map<String, dynamic> json) {
    final name = json['name'];
    if (name is! String || name.isEmpty) {
      throw const BackupFormatException(BackupFormatError.invalidContent);
    }
    return Athlete()
      ..name = name
      ..weightKg = _optionalDouble(json['weightKg'])
      ..heightCm = _optionalDouble(json['heightCm'])
      ..avatarUrl = _optionalString(json['avatarUrl'])
      ..baselineCmjHeight = _optionalDouble(json['baselineCmjHeight'])
      ..baselineDate = _optionalDate(json['baselineDate'])
      ..baselineRsi = _optionalDouble(json['baselineRsi'])
      ..latestAsymmetryPct = _optionalDouble(json['latestAsymmetryPct'])
      ..asymmetryStrongerLeg = _optionalString(json['asymmetryStrongerLeg'])
      ..asymmetryDate = _optionalDate(json['asymmetryDate'])
      ..sortOrder = _optionalInt(json['sortOrder']) ?? 0;
  }

  Map<String, Object?> _jumpTestToJson(JumpTest test) => {
    'athleteId': test.athleteId,
    'testType': test.testType,
    'timestamp': test.timestamp.toUtc().toIso8601String(),
    'takeoffFrame': test.takeoffFrame,
    'landingFrame': test.landingFrame,
    'landing1Frame': test.landing1Frame,
    'fps': test.fps,
    'flightTimeMs': test.flightTimeMs,
    'heightCm': test.heightCm,
    'deltaHCm': test.deltaHCm,
    'contactTimeMs': test.contactTimeMs,
    'rsiScore': test.rsiScore,
    'deltaRsi': test.deltaRsi,
    'dropHeightCm': test.dropHeightCm,
    'baselineAtTest': test.baselineAtTest,
    'sessionId': test.sessionId,
    'isSummary': test.isSummary,
    'isOutlier': test.isOutlier,
    'leg': test.leg,
    'landing1TimeSeconds': test.landing1TimeSeconds,
    'takeoffTimeSeconds': test.takeoffTimeSeconds,
    'landingTimeSeconds': test.landingTimeSeconds,
  };

  JumpTest _jumpTestFromJson(Map<String, dynamic> json) {
    final testType = json['testType'];
    if (testType is! String || !_knownTestTypes.contains(testType)) {
      throw const BackupFormatException(BackupFormatError.invalidContent);
    }
    final timestamp = _optionalDate(json['timestamp']);
    if (timestamp == null) {
      throw const BackupFormatException(BackupFormatError.invalidContent);
    }
    return JumpTest()
      ..athleteId = 0 // reassigned on import
      ..testType = testType
      ..timestamp = timestamp
      ..takeoffFrame = _optionalInt(json['takeoffFrame'])
      ..landingFrame = _optionalInt(json['landingFrame'])
      ..landing1Frame = _optionalInt(json['landing1Frame'])
      ..fps = _optionalDouble(json['fps'])
      ..flightTimeMs = _optionalDouble(json['flightTimeMs']) ?? 0
      ..heightCm = _optionalDouble(json['heightCm']) ?? 0
      ..deltaHCm = _optionalDouble(json['deltaHCm']) ?? 0
      ..contactTimeMs = _optionalDouble(json['contactTimeMs'])
      ..rsiScore = _optionalDouble(json['rsiScore'])
      ..deltaRsi = _optionalDouble(json['deltaRsi'])
      ..dropHeightCm = _optionalDouble(json['dropHeightCm'])
      ..baselineAtTest = _optionalDouble(json['baselineAtTest'])
      ..sessionId = _optionalInt(json['sessionId'])
      ..isSummary = json['isSummary'] is bool ? json['isSummary'] as bool : true
      ..isOutlier = json['isOutlier'] is bool
          ? json['isOutlier'] as bool
          : false
      ..leg = _optionalString(json['leg'])
      ..landing1TimeSeconds = _optionalDouble(json['landing1TimeSeconds'])
      ..takeoffTimeSeconds = _optionalDouble(json['takeoffTimeSeconds'])
      ..landingTimeSeconds = _optionalDouble(json['landingTimeSeconds']);
  }

  static int _requireInt(Object? value) {
    final parsed = _optionalInt(value);
    if (parsed == null) {
      throw const BackupFormatException(BackupFormatError.invalidContent);
    }
    return parsed;
  }

  static int? _optionalInt(Object? value) {
    if (value is int) return value;
    if (value is double && value == value.roundToDouble()) return value.toInt();
    return null;
  }

  static double? _optionalDouble(Object? value) {
    if (value is num) return value.toDouble();
    return null;
  }

  static String? _optionalString(Object? value) {
    if (value is String && value.isNotEmpty) return value;
    return null;
  }

  static DateTime? _optionalDate(Object? value) {
    if (value is! String) return null;
    return DateTime.tryParse(value)?.toLocal();
  }
}
