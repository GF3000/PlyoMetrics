import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../models/athlete.dart';
import '../models/athlete_group.dart';
import '../models/jump_test.dart';
import '../services/isar_service.dart';

/// Provides the IsarService singleton (initialized before app starts).
final isarServiceProvider = Provider<IsarService>((ref) {
  return IsarService.instance;
});

/// Stream of all groups from Isar.
final groupsProvider = StreamProvider<List<AthleteGroup>>((ref) {
  final service = ref.watch(isarServiceProvider);
  return service.watchGroups();
});

/// The currently selected group.
final activeGroupProvider = StateProvider<AthleteGroup?>((ref) => null);

/// The currently selected athlete.
final activeAthleteProvider = StateProvider<Athlete?>((ref) => null);

/// Stream of athletes belonging to the active group.
/// Re-evaluates when the active group changes or the athletes collection changes.
final groupAthletesProvider = StreamProvider<List<Athlete>>((ref) {
  final group = ref.watch(activeGroupProvider);
  if (group == null) return Stream.value([]);

  final service = ref.watch(isarServiceProvider);
  // Watch the athletes collection; reload the group's IsarLinks on each emission
  return service.db.athletes
      .where()
      .watch(fireImmediately: true)
      .asyncMap((_) async {
    await group.athletes.load();
    final list = group.athletes.toList();
    list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return list;
  });
});

/// Stream of all jump tests for the active athlete, sorted by date.
final athleteJumpHistoryProvider = StreamProvider<List<JumpTest>>((ref) {
  final athlete = ref.watch(activeAthleteProvider);
  if (athlete == null) return Stream.value([]);

  final service = ref.watch(isarServiceProvider);

  return service.db.jumpTests
      .filter()
      .athleteIdEqualTo(athlete.id)
      .sortByTimestampDesc()
      .watch(fireImmediately: true);
});

// ── Evolution Providers ──

/// Baseline (CMJ) tests for the active athlete, sorted ascending by date.
final baselineHistoryProvider = Provider<List<JumpTest>>((ref) {
  final history = ref.watch(athleteJumpHistoryProvider);
  return history.whenOrNull(
        data: (tests) => tests
            .where((t) => t.testType == 'cmj_baseline' && !t.isOutlier)
            .toList()
          ..sort((a, b) => a.timestamp.compareTo(b.timestamp)),
      ) ??
      [];
});

/// Fatigue tests for the active athlete, sorted ascending by date.
final fatigueHistoryProvider = Provider<List<JumpTest>>((ref) {
  final history = ref.watch(athleteJumpHistoryProvider);
  return history.whenOrNull(
        data: (tests) => tests
            .where((t) => t.testType == 'fatigue')
            .toList()
          ..sort((a, b) => a.timestamp.compareTo(b.timestamp)),
      ) ??
      [];
});

/// Computed stats for the Evolution tab metric cards.
final athleteEvolutionStatsProvider =
    FutureProvider<({String title1, String val1, String title2, String val2, bool isPositive1, bool isPositive2})>((ref) async {
  final mode = ref.watch(historyModeProvider);
  final athlete = ref.watch(activeAthleteProvider);
  final groupAthletesAsync = ref.watch(groupAthletesProvider);
  final service = ref.watch(isarServiceProvider);

  if (mode == 0) {
    // CMJ mode
    final baselines = ref.watch(baselineHistoryProvider);
    final groupAthletes = groupAthletesAsync.whenOrNull(data: (l) => l) ?? [];

    // Height gain: current baseline minus earliest recorded baseline height
    double? heightGain;
    if (baselines.isNotEmpty && athlete?.baselineCmjHeight != null) {
      heightGain = athlete!.baselineCmjHeight! - baselines.first.heightCm;
    }

    // Group mean comparison
    double? groupMeanDiff;
    if (athlete?.baselineCmjHeight != null && groupAthletes.length > 1) {
      final withBaseline = groupAthletes.where((a) => a.baselineCmjHeight != null).toList();
      if (withBaseline.length > 1) {
        final mean = withBaseline.map((a) => a.baselineCmjHeight!).reduce((a, b) => a + b) / withBaseline.length;
        groupMeanDiff = athlete!.baselineCmjHeight! - mean;
      }
    }

    String title1 = 'Height Gain';
    String val1 = heightGain == null ? '—' : '${heightGain >= 0 ? '+' : ''}${heightGain.toStringAsFixed(1)} cm';
    bool isPositive1 = heightGain == null ? false : heightGain >= 0;

    String title2 = 'vs Group Mean';
    String val2 = groupMeanDiff == null ? '—' : '${groupMeanDiff >= 0 ? '+' : ''}${groupMeanDiff.toStringAsFixed(1)} cm';
    bool isPositive2 = groupMeanDiff == null ? false : groupMeanDiff >= 0;

    return (title1: title1, val1: val1, title2: title2, val2: val2, isPositive1: isPositive1, isPositive2: isPositive2);
  } else {
    // RSI mode
    final rsiTests = ref.watch(rsiHistoryProvider);
    final groupAthletes = groupAthletesAsync.whenOrNull(data: (l) => l) ?? [];

    // RSI gain: latest minus first, if >=2 tests
    double gain = 0.00;
    if (rsiTests.length >= 2) {
      gain = rsiTests.last.rsiScore! - rsiTests.first.rsiScore!;
    }
    String val1 = '${gain >= 0 && gain != 0 ? '+' : gain < 0 ? '' : ''}${gain.toStringAsFixed(2)}';
    bool isPositive1 = gain > 0;

    // RSI vs group mean: active max RSI minus group average max RSI
    double? activeMaxRsi;
    if (rsiTests.isNotEmpty) {
      activeMaxRsi = rsiTests.map((t) => t.rsiScore!).reduce((a, b) => a > b ? a : b);
    }

    double? groupMean;
    if (groupAthletes.isNotEmpty) {
      List<double> maxes = [];
      for (final a in groupAthletes) {
        final tests = await service.db.jumpTests.filter().athleteIdEqualTo(a.id).testTypeEqualTo('rsi').findAll();
        if (tests.isNotEmpty) {
          final validScores = tests.map((t) => t.rsiScore).where((r) => r != null).cast<double>();
          if (validScores.isNotEmpty) {
            final maxRsi = validScores.reduce((a, b) => a > b ? a : b);
            maxes.add(maxRsi);
          }
        }
      }
      if (maxes.isNotEmpty) {
        groupMean = maxes.reduce((a, b) => a + b) / maxes.length;
      }
    }

    double? diff;
    if (activeMaxRsi != null && groupMean != null) {
      diff = activeMaxRsi - groupMean;
    }

    String title1 = 'RSI Gain';
    String title2 = 'vs Group Mean';
    String val2 = diff == null ? '—' : '${diff >= 0 ? '+' : ''}${diff.toStringAsFixed(2)}';
    bool isPositive2 = diff == null ? false : diff > 0;

    return (title1: title1, val1: val1, title2: title2, val2: val2, isPositive1: isPositive1, isPositive2: isPositive2);
  }
});

/// RSI test history for the active athlete, sorted chronologically.
final rsiHistoryProvider = Provider<List<JumpTest>>((ref) {
  final history = ref.watch(athleteJumpHistoryProvider);
  return history.whenOrNull(
        data: (tests) => tests
            .where((t) => t.testType == 'rsi')
            .toList()
          ..sort((a, b) => a.timestamp.compareTo(b.timestamp)),
      ) ??
      [];
});

/// The current mode for history/evolution screens: 0 = CMJ & Fatigue, 1 = RSI.
final historyModeProvider = StateProvider<int>((ref) => 0);
