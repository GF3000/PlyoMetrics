import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../models/athlete.dart';
import '../models/athlete_group.dart';
import '../providers/management_providers.dart';
import '../services/isar_service.dart';
import '../providers/cmj_session_provider.dart';
import '../widgets/add_athlete_dialog.dart';
import '../widgets/add_group_dialog.dart';
import '../widgets/delete_athlete_dialog.dart';
import '../widgets/edit_athlete_dialog.dart';
import 'cmj_baseline_screen.dart';
import 'athlete_history_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedNavIndex = 0;
  bool _rosterExpanded = false;

  @override
  Widget build(BuildContext context) {
    // Auto-select first group when groups load and nothing is selected
    ref.listen(groupsProvider, (prev, next) {
      next.whenData((groups) {
        final active = ref.read(activeGroupProvider);
        if (active == null && groups.isNotEmpty) {
          ref.read(activeGroupProvider.notifier).state = groups.first;
        }
      });
    });

    // Auto-select first athlete when group athletes load
    ref.listen(groupAthletesProvider, (prev, next) {
      next.whenData((athletes) {
        final active = ref.read(activeAthleteProvider);
        if (athletes.isEmpty) {
          ref.read(activeAthleteProvider.notifier).state = null;
        } else if (active == null ||
            !athletes.any((a) => a.id == active.id)) {
          ref.read(activeAthleteProvider.notifier).state = athletes.first;
        }
      });
    });

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  spacing: 16,
                  children: [
                    _buildAthleteCard(),
                    _buildActionCard(
                      tag: 'PERFORMANCE',
                      title: 'CMJ Baseline Measurement',
                      subtitle: 'Vertical jump metrics & flight time',
                      icon: Icons.trending_up,
                      hasGlow: true,
                      onTap: () {
                        final athlete = ref.read(activeAthleteProvider);
                        if (athlete == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Please select an athlete first'),
                            ),
                          );
                          return;
                        }
                        ref.read(cmjSessionProvider.notifier).reset();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const CmjBaselineScreen(),
                          ),
                        );
                      },
                    ),
                    _buildActionCard(
                      tag: 'MONITORING',
                      title: 'Readiness / Fatigue Test',
                      subtitle: 'Daily CNS & recovery tracking',
                      icon: Icons.check_circle_outline,
                    ),
                    _buildActionCard(
                      tag: 'REACTIVE STRENGTH',
                      title: 'RSI Drop Jump Test',
                      subtitle: 'Ground contact & efficiency',
                      icon: Icons.timer_outlined,
                    ),
                  ],
                ),
              ),
            ),
            _buildAthleteRoster(),
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  // ── Header with title + group dropdown ──

  Widget _buildHeader() {
    final groupsAsync = ref.watch(groupsProvider);
    final activeGroup = ref.watch(activeGroupProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.borderSubtle, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'PlyoMetrics',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.brand,
              letterSpacing: -0.5,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: groupsAsync.when(
                  loading: () => const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  error: (_, __) => const Text('Error',
                      style: TextStyle(color: Colors.red)),
                  data: (groups) {
                    if (groups.isEmpty) {
                      return const Text(
                        'No groups',
                        style:
                            TextStyle(color: AppColors.textSecondary, fontSize: 14),
                      );
                    }
                    return DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: activeGroup?.id,
                        isDense: true,
                        dropdownColor: AppColors.card,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        icon: const Icon(Icons.keyboard_arrow_down,
                            color: Colors.white, size: 18),
                        items: groups
                            .map((g) => DropdownMenuItem<int>(
                                value: g.id, child: Text(g.name)))
                            .toList(),
                        onChanged: (id) {
                          if (id == null) return;
                          final group = groups.firstWhere((g) => g.id == id);
                          ref.read(activeGroupProvider.notifier).state = group;
                          // Reset athlete selection when switching groups
                          ref.read(activeAthleteProvider.notifier).state = null;
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              _buildAddGroupButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddGroupButton() {
    return GestureDetector(
      onTap: () async {
        final group = await showDialog<AthleteGroup>(
          context: context,
          builder: (_) => const AddGroupDialog(),
        );
        if (group != null) {
          ref.read(activeGroupProvider.notifier).state = group;
          ref.read(activeAthleteProvider.notifier).state = null;
        }
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.add, color: AppColors.brand, size: 18),
      ),
    );
  }

  // ── Selected athlete profile card ──

  Widget _buildAthleteCard() {
    final athlete = ref.watch(activeAthleteProvider);

    if (athlete == null) {
      return Container(/* ... existing placeholder code ... */);
    }

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AthleteHistoryScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(80),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar ...
            Stack(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.brand, width: 2),
                  ),
                  padding: const EdgeInsets.all(2),
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.card,
                    child: Text(
                      athlete.name[0],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.brand,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.card, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            // Name + meta
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        athlete.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: AppColors.textTertiary),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.fitness_center,
                          size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        '${athlete.weightKg.toInt()}kg',
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.textSecondary),
                      ),
                      if (athlete.baselineCmjHeight != null) ...[
                        const SizedBox(width: 12),
                        const Icon(Icons.height,
                            size: 14, color: AppColors.brand),
                        const SizedBox(width: 4),
                        Text(
                          '${athlete.baselineCmjHeight!.toStringAsFixed(1)}cm',
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.brand),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  // ── Action card (CMJ, Fatigue, RSI) ──

  Widget _buildActionCard({
    required String tag,
    required String title,
    required String subtitle,
    required IconData icon,
    bool hasGlow = false,
    VoidCallback? onTap,
  }) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap ?? () {},
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.borderSubtle),
            boxShadow: hasGlow
                ? [
                    BoxShadow(
                      color: AppColors.brand.withAlpha(50),
                      blurRadius: 10,
                    )
                  ]
                : null,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tag,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.brand,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.brand.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.brand, size: 24),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Bottom athlete roster (horizontal scroll) ──

  Widget _buildAthleteRoster() {
    final athletesAsync = ref.watch(groupAthletesProvider);
    final activeAthlete = ref.watch(activeAthleteProvider);
    final activeGroup = ref.watch(activeGroupProvider);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.borderSubtle, width: 1),
        ),
      ),
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'ATHLETE ROSTER',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textTertiary,
                    letterSpacing: 1,
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _rosterExpanded = !_rosterExpanded),
                  child: Text(
                    _rosterExpanded ? 'Collapse' : 'View All',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.brand,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          athletesAsync.when(
            loading: () => const SizedBox(
              height: 80,
              child: Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            error: (_, __) => const SizedBox(
              height: 80,
              child: Center(
                child: Text('Error loading athletes',
                    style: TextStyle(color: Colors.red)),
              ),
            ),
            data: (athletes) => _rosterExpanded
                ? _buildExpandedRoster(athletes, activeAthlete, activeGroup)
                : SizedBox(
                    height: 80,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: athletes.length + 1,
                      separatorBuilder: (_, __) => const SizedBox(width: 20),
                      itemBuilder: (context, index) {
                        if (index == athletes.length) {
                          return _buildAddAthleteButton(activeGroup);
                        }
                        final athlete = athletes[index];
                        final isSelected = athlete.id == activeAthlete?.id;
                        return _buildAthleteAvatar(athlete, isSelected);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedRoster(
      List<Athlete> athletes, Athlete? activeAthlete, AthleteGroup? activeGroup) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 300),
      child: ReorderableListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: athletes.length,
        proxyDecorator: (child, index, animation) {
          return Material(
            color: Colors.transparent,
            elevation: 4,
            shadowColor: Colors.black54,
            borderRadius: BorderRadius.circular(8),
            child: child,
          );
        },
        onReorder: (oldIndex, newIndex) {
          if (newIndex > oldIndex) newIndex--;
          final reordered = List<Athlete>.from(athletes);
          final item = reordered.removeAt(oldIndex);
          reordered.insert(newIndex, item);
          IsarService.instance.reorderAthletes(reordered);
        },
        footer: _buildAddAthleteRow(activeGroup),
        itemBuilder: (context, index) {
          final athlete = athletes[index];
          final isSelected = athlete.id == activeAthlete?.id;
          return _buildAthleteRow(athlete, isSelected);
        },
      ),
    );
  }

  Widget _buildAthleteRow(Athlete athlete, bool isSelected) {
    return Container(
      key: ValueKey(athlete.id),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.card : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isSelected
            ? Border.all(color: AppColors.brand.withAlpha(80))
            : null,
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        leading: CircleAvatar(
          radius: 18,
          backgroundColor: isSelected ? AppColors.card : AppColors.card.withAlpha(180),
          child: Text(
            athlete.name[0],
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isSelected ? AppColors.brand : AppColors.textSecondary,
            ),
          ),
        ),
        title: Text(
          athlete.name,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
        subtitle: Text(
          '${athlete.weightKg.toInt()} kg',
          style: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 18),
              color: AppColors.textSecondary,
              onPressed: () async {
                final updated = await showDialog<Athlete>(
                  context: context,
                  builder: (_) => EditAthleteDialog(athlete: athlete),
                );
                if (updated != null &&
                    ref.read(activeAthleteProvider)?.id == updated.id) {
                  ref.read(activeAthleteProvider.notifier).state = updated;
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18),
              color: AppColors.textSecondary,
              onPressed: () async {
                final deleted = await showDialog<bool>(
                  context: context,
                  builder: (_) => DeleteAthleteDialog(athlete: athlete),
                );
                if (deleted == true) {
                  final active = ref.read(activeAthleteProvider);
                  if (active?.id == athlete.id) {
                    ref.read(activeAthleteProvider.notifier).state = null;
                  }
                }
              },
            ),
          ],
        ),
        onTap: () =>
            ref.read(activeAthleteProvider.notifier).state = athlete,
      ),
    );
  }

  Widget _buildAddAthleteRow(AthleteGroup? group) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.textTertiary, width: 1.5),
          ),
          child: const Center(
            child: Icon(Icons.add, color: AppColors.textTertiary, size: 18),
          ),
        ),
      ),
      title: const Text(
        'Add Athlete',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textTertiary,
        ),
      ),
      onTap: group == null
          ? null
          : () async {
              final athlete = await showDialog<Athlete>(
                context: context,
                builder: (_) => AddAthleteDialog(group: group),
              );
              if (athlete != null) {
                ref.read(activeAthleteProvider.notifier).state = athlete;
              }
            },
    );
  }

  Widget _buildAthleteAvatar(Athlete athlete, bool isSelected) {
    return GestureDetector(
      onTap: () =>
          ref.read(activeAthleteProvider.notifier).state = athlete,
      onLongPress: () async {
        final deleted = await showDialog<bool>(
          context: context,
          builder: (_) => DeleteAthleteDialog(athlete: athlete),
        );
        if (deleted == true) {
          final active = ref.read(activeAthleteProvider);
          if (active?.id == athlete.id) {
            ref.read(activeAthleteProvider.notifier).state = null;
          }
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: AppColors.brand, width: 2)
                  : null,
            ),
            padding: isSelected ? const EdgeInsets.all(2) : null,
            child: CircleAvatar(
              radius: 24,
              backgroundColor:
                  isSelected ? AppColors.card : AppColors.card.withAlpha(180),
              child: Text(
                athlete.name[0],
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppColors.brand : AppColors.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            athlete.name,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: isSelected ? AppColors.brand : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddAthleteButton(AthleteGroup? group) {
    return GestureDetector(
      onTap: group == null
          ? null
          : () async {
              final athlete = await showDialog<Athlete>(
                context: context,
                builder: (_) => AddAthleteDialog(group: group),
              );
              if (athlete != null) {
                ref.read(activeAthleteProvider.notifier).state = athlete;
              }
            },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.textTertiary,
                width: 2,
                strokeAlign: BorderSide.strokeAlignInside,
              ),
            ),
            child:
                const Icon(Icons.add, color: AppColors.textTertiary, size: 24),
          ),
          const SizedBox(height: 4),
          const Text(
            'Add',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom navigation bar ──

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(
          top: BorderSide(color: AppColors.borderLight, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavItem(Icons.home_outlined, 'Home', 0),
          _buildNavItem(Icons.bar_chart, 'Evolution', 1),
          // Center FAB-style button
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 48,
              height: 48,
              transform: Matrix4.translationValues(0, -16, 0),
              decoration: BoxDecoration(
                color: AppColors.brand,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.surface, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.brand.withAlpha(50),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: const Icon(Icons.add, color: Colors.black, size: 24),
            ),
          ),
          _buildNavItem(Icons.access_time, 'Log', 3),
          _buildNavItem(Icons.person_outline, 'Profile', 4),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isActive = _selectedNavIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedNavIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 24,
            color: isActive ? AppColors.brand : AppColors.textTertiary,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isActive ? AppColors.brand : AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
