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
    Provider<({double? heightGainCm, double? groupMeanDiffCm})>((ref) {
  final athlete = ref.watch(activeAthleteProvider);
  final baselines = ref.watch(baselineHistoryProvider);
  final groupAthletes = ref.watch(groupAthletesProvider);

  // Height gain: current baseline minus earliest recorded baseline height
  double? heightGain;
  if (baselines.isNotEmpty && athlete?.baselineCmjHeight != null) {
    heightGain = athlete!.baselineCmjHeight! - baselines.first.heightCm;
  }

  // Group mean comparison
  double? groupMeanDiff;
  if (athlete?.baselineCmjHeight != null) {
    final withBaseline = groupAthletes.whenOrNull(
            data: (list) =>
                list.where((a) => a.baselineCmjHeight != null).toList()) ??
        [];
    if (withBaseline.length > 1) {
      final mean = withBaseline
              .map((a) => a.baselineCmjHeight!)
              .reduce((a, b) => a + b) /
          withBaseline.length;
      groupMeanDiff = athlete!.baselineCmjHeight! - mean;
    }
  }

  return (heightGainCm: heightGain, groupMeanDiffCm: groupMeanDiff);
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
