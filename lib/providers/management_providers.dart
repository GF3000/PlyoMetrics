import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../models/athlete.dart';
import '../models/athlete_group.dart';
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
    return group.athletes.toList();
  });
});
