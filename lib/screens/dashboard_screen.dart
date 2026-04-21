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
import 'asymmetry_test_screen.dart';
import 'cmj_baseline_screen.dart';
import 'athlete_history_screen.dart';
import 'evolution_screen.dart';
import 'fatigue_test_screen.dart';
import 'rsi_test_screen.dart';
import '../providers/asymmetry_session_provider.dart';
import '../providers/rsi_session_provider.dart';
import '../l10n/app_localizations.dart';
import 'group_overview_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedNavIndex = 0;
  bool _rosterExpanded = false;
  List<Athlete>? _reorderedAthletes;

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
        } else if (active == null || !athletes.any((a) => a.id == active.id)) {
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
              child: IndexedStack(
                index: const [0, 1, -1, 2, 3][_selectedNavIndex],
                children: [
                  _buildHomeTab(),
                  const EvolutionScreen(),
                  const AthleteHistoryScreen(),
                  const GroupOverviewScreen(),
                ],
              ),
            ),
            if (_selectedNavIndex != 4) _buildAthleteRoster(),
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  // ── Header with title + group dropdown ──

  Widget _buildHeader() {
    final l = AppLocalizations.of(context)!;
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
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Plyo',
                  style: const TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                TextSpan(
                  text: 'Metrics',
                  style: const TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.brand,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          groupsAsync.when(
            loading: () => const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            error: (_, __) =>
                Text(l.error, style: const TextStyle(color: Colors.red)),
            data: (groups) {
              if (groups.isEmpty) {
                return GestureDetector(
                  onTap: () async {
                    final group = await showDialog<AthleteGroup>(
                      context: context,
                      builder: (_) => const AddGroupDialog(),
                    );
                    if (group != null && mounted) {
                      ref.read(activeGroupProvider.notifier).state = group;
                      ref.read(activeAthleteProvider.notifier).state = null;
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.brand.withAlpha(100)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.add, color: AppColors.brand, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          l.newGroup,
                          style: const TextStyle(
                            color: AppColors.brand,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return PopupMenuButton<int>(
                initialValue: activeGroup?.id,
                tooltip: l.selectGroup,
                color: AppColors.card,
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.borderLight),
                ),
                position: PopupMenuPosition.under,
                offset: const Offset(0, 8),
                onSelected: (id) async {
                  if (id == -1) {
                    // "New Group" selected
                    final group = await showDialog<AthleteGroup>(
                      context: context,
                      builder: (_) => const AddGroupDialog(),
                    );
                    if (group != null && mounted) {
                      ref.read(activeGroupProvider.notifier).state = group;
                      ref.read(activeAthleteProvider.notifier).state = null;
                    }
                  } else {
                    // Existing group selected
                    final group = groups.firstWhere((g) => g.id == id);
                    ref.read(activeGroupProvider.notifier).state = group;
                    ref.read(activeAthleteProvider.notifier).state = null;
                  }
                },
                itemBuilder: (context) {
                  final items = groups.map((g) {
                    final isSelected = g.id == activeGroup?.id;
                    return PopupMenuItem<int>(
                      value: g.id,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              g.name,
                              style: TextStyle(
                                color: isSelected
                                    ? AppColors.brand
                                    : Colors.white,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isSelected)
                                const Icon(
                                  Icons.check,
                                  color: AppColors.brand,
                                  size: 18,
                                ),
                              const SizedBox(width: 4),
                              IconButton(
                                icon: const Icon(
                                  Icons.more_vert,
                                  color: AppColors.textSecondary,
                                  size: 20,
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () {
                                  Navigator.pop(
                                    context,
                                  ); // Dismiss the popup menu
                                  _showGroupOptions(
                                    context,
                                    g,
                                    groups,
                                  ); // Open bottom sheet
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList();

                  // Append the Add Group button to the bottom of the list
                  items.add(
                    PopupMenuItem<int>(
                      value: -1,
                      child: Row(
                        children: [
                          const Icon(
                            Icons.add,
                            color: AppColors.brand,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l.newGroup,
                            style: const TextStyle(
                              color: AppColors.brand,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );

                  return items;
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        activeGroup?.name ?? l.selectGroup,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.textSecondary,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Home tab content ──

  Widget _buildHomeTab() {
    final l = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        spacing: 16,
        children: [
          _buildAthleteCard(),
          _buildCmjCard(l),
          _buildFatigueCard(l),
          _buildRsiCard(l),
          _buildAsymmetryCard(l),
        ],
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
      onTap: () => setState(() => _selectedNavIndex = 3),
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
                      const Icon(
                        Icons.chevron_right,
                        color: AppColors.textTertiary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      // CMJ Baseline
                      const Icon(
                        Icons.trending_up,
                        size: 14,
                        color: AppColors.brand,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        athlete.baselineCmjHeight != null
                            ? '${athlete.baselineCmjHeight!.toStringAsFixed(1)} cm'
                            : 'No data',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.brand,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // RSI Score
                      const Icon(Icons.speed, size: 14, color: AppColors.brand),
                      const SizedBox(width: 4),
                      Text(
                        athlete.baselineRsi != null
                            ? '${athlete.baselineRsi!.toStringAsFixed(2)} RSI'
                            : 'No data',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.brand,
                        ),
                      ),
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
  // ── Dynamic action cards ──

  static const _warningAmber = Color(0xFFFBBF24);

  Widget _buildCmjCard(AppLocalizations l) {
    final athlete = ref.watch(activeAthleteProvider);

    String subtitle = l.verticalJumpMetricsFlightTime;
    Color? subtitleColor;
    bool needsAttention = false;

    if (athlete != null) {
      if (athlete.baselineDate == null) {
        subtitle = l.noBaselineSet;
        subtitleColor = _warningAmber;
        needsAttention = true;
      } else {
        final daysSince = DateTime.now()
            .difference(athlete.baselineDate!)
            .inDays;
        if (daysSince >= 28) {
          subtitle = l.baselineOutdated(daysSince);
          subtitleColor = _warningAmber;
          needsAttention = true;
        } else {
          subtitle = l.baselineWithDate(
            athlete.baselineCmjHeight?.toStringAsFixed(1) ?? '-',
            '${athlete.baselineDate!.day}/${athlete.baselineDate!.month}/${athlete.baselineDate!.year}',
          );
        }
      }
    }

    return _buildActionCard(
      tag: l.tagPerformance,
      title: l.cmjBaselineMeasurement,
      subtitle: subtitle,
      subtitleColor: subtitleColor,
      icon: Icons.trending_up,
      hasGlow: needsAttention,
      onTap: () => _launchCmjBaseline(context, AppLocalizations.of(context)!),
    );
  }

  void _launchCmjBaseline(BuildContext ctx, AppLocalizations l) {
    final athletes = ref.read(groupAthletesProvider).valueOrNull ?? [];
    if (athletes.isEmpty) {
      ScaffoldMessenger.of(
        ctx,
      ).showSnackBar(SnackBar(content: Text(l.pleaseSelectGroupFirst)));
      return;
    }
    final activeAthlete = ref.read(activeAthleteProvider);
    ref
        .read(cmjSessionProvider.notifier)
        .initWithAthletes(athletes, defaultAthleteId: activeAthlete?.id);
    Navigator.of(ctx).push(
      MaterialPageRoute(builder: (_) => CmjBaselineScreen(athletes: athletes)),
    );
  }

  void _launchRsiTest(BuildContext ctx, AppLocalizations l) {
    final groupAthletes = ref.read(groupAthletesProvider).valueOrNull ?? [];
    final active = ref.read(activeAthleteProvider);

    if (active == null && groupAthletes.isEmpty) {
      ScaffoldMessenger.of(
        ctx,
      ).showSnackBar(SnackBar(content: Text(l.selectAnAthleteFirst)));
      return;
    }

    final athletes = groupAthletes.isNotEmpty ? groupAthletes : [active!];
    ref
        .read(rsiSessionProvider.notifier)
        .initWithAthletes(athletes, defaultAthleteId: active?.id);
    Navigator.of(ctx).push(
      MaterialPageRoute(builder: (_) => RsiTestScreen(athletes: athletes)),
    );
  }

  Widget _buildFatigueCard(AppLocalizations l) {
    final athlete = ref.watch(activeAthleteProvider);

    String subtitle = l.dailyCnsRecoveryTracking;
    Color? subtitleColor;
    bool hasRecentFatigue = false;

    // Only show dynamic data if athlete has a recent CMJ baseline
    final hasRecentBaseline =
        athlete != null &&
        athlete.baselineDate != null &&
        DateTime.now().difference(athlete.baselineDate!).inDays < 28;

    if (athlete != null && athlete.baselineCmjHeight != null) {
      final latestFatigueAsync = ref.watch(latestFatigueTestProvider);
      subtitle = latestFatigueAsync.when(
        data: (test) {
          if (test != null &&
              DateTime.now().difference(test.timestamp).inHours <= 12) {
            hasRecentFatigue = true;
            final lossPercent =
                ((test.baselineAtTest! - test.heightCm) /
                test.baselineAtTest! *
                100);
            String status;
            if (lossPercent <= 5) {
              status = l.fatigueOptimal;
              subtitleColor = Colors.green;
            } else if (lossPercent <= 10) {
              status = l.fatigueModerate;
              subtitleColor = _warningAmber;
            } else {
              status = l.fatigueHigh;
              subtitleColor = const Color(0xFFEF4444);
            }
            return l.todayFatigueLoss(lossPercent.round().toString(), status);
          }
          return l.pendingDailyTest;
        },
        loading: () => l.dailyCnsRecoveryTracking,
        error: (_, __) => l.dailyCnsRecoveryTracking,
      );
    }

    return _buildActionCard(
      tag: l.tagMonitoring,
      title: l.readinessFatigueTest,
      subtitle: subtitle,
      subtitleColor: subtitleColor,
      icon: Icons.check_circle_outline,
      hasGlow: hasRecentBaseline && !hasRecentFatigue,
      onTap: () {
        final athlete = ref.read(activeAthleteProvider);
        if (athlete == null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l.pleaseSelectAthleteFirst)));
          return;
        }
        if (athlete.baselineCmjHeight == null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l.completeCmjBaselineFirst)));
          return;
        }
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const FatigueTestScreen()));
      },
    );
  }

  Widget _buildRsiCard(AppLocalizations l) {
    final athlete = ref.watch(activeAthleteProvider);

    String subtitle = l.groundContactEfficiency;
    if (athlete != null && athlete.baselineRsi != null) {
      subtitle = l.rsiBaselineValue(athlete.baselineRsi!.toStringAsFixed(2));
    }

    return _buildActionCard(
      tag: l.tagReactiveStrength,
      title: l.rsiDropJumpTest,
      subtitle: subtitle,
      icon: Icons.timer_outlined,
      onTap: () => _launchRsiTest(context, l),
    );
  }

  Widget _buildAsymmetryCard(AppLocalizations l) {
    final athlete = ref.watch(activeAthleteProvider);
    String subtitle = l.singleLegCmj;
    bool hasGlow = false;

    if (athlete != null && athlete.latestAsymmetryPct != null) {
      final pct = athlete.latestAsymmetryPct!;
      final legLabel = athlete.asymmetryStrongerLeg == 'right'
          ? l.rightStrongerLabel
          : l.leftStrongerLabel;
      subtitle = '${pct >= 0 ? '+' : ''}${pct.round()}% ($legLabel)';
      hasGlow = pct.abs() >= 15;
    }

    return _buildActionCard(
      tag: l.tagAsymmetry,
      title: l.asymmetricTest,
      subtitle: subtitle,
      icon: Icons.compare_arrows,
      hasGlow: hasGlow,
      onTap: () => _launchAsymmetryTest(context, l),
    );
  }

  Future<void> _launchAsymmetryTest(
    BuildContext ctx,
    AppLocalizations l,
  ) async {
    final athletesAsync = ref.read(groupAthletesProvider);
    final athletes = athletesAsync.whenOrNull(data: (l) => l) ?? [];
    if (athletes.isEmpty) {
      ScaffoldMessenger.of(
        ctx,
      ).showSnackBar(SnackBar(content: Text(l.pleaseSelectGroupFirst)));
      return;
    }
    final active = ref.read(activeAthleteProvider);
    ref
        .read(asymmetrySessionProvider.notifier)
        .initWithAthletes(athletes, defaultAthleteId: active?.id);
    Navigator.of(ctx).push(
      MaterialPageRoute(
        builder: (_) => AsymmetryTestScreen(athletes: athletes),
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
    Color? subtitleColor,
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
                    ),
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
                      style: TextStyle(
                        fontSize: 13,
                        color: subtitleColor ?? AppColors.textSecondary,
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
    final l = AppLocalizations.of(context)!;
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
                Text(
                  l.athleteRoster,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textTertiary,
                    letterSpacing: 1,
                  ),
                ),
                GestureDetector(
                  onTap: () =>
                      setState(() => _rosterExpanded = !_rosterExpanded),
                  child: Text(
                    _rosterExpanded ? l.collapse : l.viewAll,
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
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            error: (_, __) => SizedBox(
              height: 80,
              child: Center(
                child: Text(
                  l.errorLoadingAthletes,
                  style: const TextStyle(color: Colors.red),
                ),
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

  bool _listOrderMatches(List<Athlete> a, List<Athlete> b) {
    for (int i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id) return false;
    }
    return true;
  }

  Widget _buildExpandedRoster(
    List<Athlete> athletes,
    Athlete? activeAthlete,
    AthleteGroup? activeGroup,
  ) {
    // Use optimistic local order if available, otherwise use stream data
    final displayAthletes = _reorderedAthletes ?? athletes;
    // Clear the override once the stream catches up with the same order
    if (_reorderedAthletes != null &&
        _reorderedAthletes!.length == athletes.length &&
        _listOrderMatches(_reorderedAthletes!, athletes)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _reorderedAthletes = null);
      });
    }
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 300),
      child: ReorderableListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: displayAthletes.length,
        proxyDecorator: (child, index, animation) {
          return AnimatedBuilder(
            animation: animation,
            builder: (BuildContext context, Widget? child) {
              // Scale up by 4% when fully lifted
              final double scale = 1.0 + (animation.value * 0.04);
              return Transform.scale(
                scale: scale,
                child: Material(
                  color: AppColors.card,
                  elevation: 12, // Stronger shadow
                  shadowColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: AppColors.brand.withAlpha(
                        (animation.value * 255).toInt(),
                      ),
                      width: 1.5,
                    ),
                  ),
                  child: child,
                ),
              );
            },
            child: child,
          );
        },
        onReorder: (oldIndex, newIndex) {
          if (newIndex > oldIndex) newIndex--;
          final reordered = List<Athlete>.from(displayAthletes);
          final item = reordered.removeAt(oldIndex);
          reordered.insert(newIndex, item);
          setState(() => _reorderedAthletes = reordered);
          IsarService.instance.reorderAthletes(reordered);
        },
        footer: _buildAddAthleteRow(activeGroup),
        itemBuilder: (context, index) {
          final athlete = displayAthletes[index];
          final isSelected = athlete.id == activeAthlete?.id;
          return _buildAthleteRow(athlete, isSelected, index);
        },
      ),
    );
  }

  Widget _buildAthleteRow(Athlete athlete, bool isSelected, int index) {
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
          backgroundColor: isSelected
              ? AppColors.card
              : AppColors.card.withAlpha(180),
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
          '${athlete.heightCm != null ? '${athlete.heightCm!.toInt()} cm' : '— cm'} | ${athlete.weightKg != null ? '${athlete.weightKg!.toInt()} kg' : '— kg'}',
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
        onTap: () => ref.read(activeAthleteProvider.notifier).state = athlete,
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
      title: Text(
        AppLocalizations.of(context)!.addAthlete,
        style: const TextStyle(
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
      onTap: () => ref.read(activeAthleteProvider.notifier).state = athlete,
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
              backgroundColor: isSelected
                  ? AppColors.card
                  : AppColors.card.withAlpha(180),
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
            child: const Icon(
              Icons.add,
              color: AppColors.textTertiary,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppLocalizations.of(context)!.add,
            style: const TextStyle(
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
    final l = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(top: BorderSide(color: AppColors.borderLight, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavItem(Icons.home_outlined, l.navHome, 0),
          _buildNavItem(Icons.bar_chart, l.navEvolution, 1),
          // Center FAB-style button
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (_selectedNavIndex == 4) {
                  _showAddAthleteToGroup();
                } else {
                  _showNewTestMenu(context);
                }
              },
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
                child: Material(
                  color: AppColors.brand,
                  shape: const CircleBorder(),
                  clipBehavior: Clip
                      .antiAlias, // Ensures the ripple stays inside the circle
                  child: InkWell(
                    onTap: () {
                      if (_selectedNavIndex == 4) {
                        _showAddAthleteToGroup();
                      } else {
                        _showNewTestMenu(context);
                      }
                    },
                    splashColor: Colors
                        .black26, // A subtle dark ripple looks great on the bright brand color
                    highlightColor: Colors.black12,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        key: ValueKey(_selectedNavIndex == 4),
                        _selectedNavIndex == 4 ? Icons.person_add : Icons.add,
                        color: Colors.black,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          _buildNavItem(Icons.access_time, l.navLog, 3),
          _buildNavItem(Icons.groups_outlined, l.navGroup, 4),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isActive = _selectedNavIndex == index;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          setState(() => _selectedNavIndex = index);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
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
        ),
      ),
    );
  }

  void _showGroupOptions(
    BuildContext context,
    AthleteGroup group,
    List<AthleteGroup> allGroups,
  ) {
    final l = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                group.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
            ),
            const Divider(color: AppColors.borderLight, height: 1),
            ListTile(
              leading: const Icon(
                Icons.edit_outlined,
                color: AppColors.textPrimary,
              ),
              title: Text(
                l.renameGroup,
                style: const TextStyle(color: AppColors.textPrimary),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _renameGroup(context, group);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.delete_outline,
                color: Colors.redAccent,
              ),
              title: Text(
                l.deleteGroup,
                style: const TextStyle(color: Colors.redAccent),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _deleteGroup(context, group, allGroups);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _renameGroup(BuildContext context, AthleteGroup group) async {
    final l = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: group.name);
    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text(l.renameGroup, style: const TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: l.groupName,
            labelStyle: const TextStyle(color: AppColors.textSecondary),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: AppColors.borderLight),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: AppColors.brand),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text(l.save),
          ),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty && newName != group.name) {
      final updatedGroup = await IsarService.instance.updateGroup(
        group,
        newName,
      );
      if (ref.read(activeGroupProvider)?.id == updatedGroup.id) {
        ref.read(activeGroupProvider.notifier).state = updatedGroup;
      }
    }
  }

  Future<void> _deleteGroup(
    BuildContext context,
    AthleteGroup group,
    List<AthleteGroup> allGroups,
  ) async {
    final l = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text(l.deleteGroup, style: const TextStyle(color: Colors.white)),
        content: Text(
          l.confirmDeleteGroup(group.name),
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.delete),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await IsarService.instance.deleteGroup(group.id);
      if (ref.read(activeGroupProvider)?.id == group.id) {
        final remainingGroups = allGroups
            .where((g) => g.id != group.id)
            .toList();
        ref.read(activeGroupProvider.notifier).state =
            remainingGroups.isNotEmpty ? remainingGroups.first : null;
        ref.read(activeAthleteProvider.notifier).state = null;
      }
    }
  }

  void _showNewTestMenu(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle pill
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              l.newMeasurement,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // CMJ Baseline Option
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.brand.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.trending_up, color: AppColors.brand),
              ),
              title: Text(
                l.cmjBaseline,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                l.verticalJumpMetrics,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              onTap: () {
                Navigator.pop(ctx); // Dismiss the sheet
                _launchCmjBaseline(context, l);
              },
            ),
            // Fatigue Test Option
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.brand.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  color: AppColors.brand,
                ),
              ),
              title: Text(
                l.fatigueTest,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                l.dailyReadinessTracking,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              onTap: () {
                Navigator.pop(ctx);
                final athlete = ref.read(activeAthleteProvider);
                if (athlete == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l.pleaseSelectAthleteFirst)),
                  );
                  return;
                }
                if (athlete.baselineCmjHeight == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l.completeCmjBaselineFirst)),
                  );
                  return;
                }
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const FatigueTestScreen()),
                );
              },
            ),
            // RSI Test Option
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.brand.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.timer_outlined, color: AppColors.brand),
              ),
              title: Text(
                l.rsiDropJump,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                l.groundContactEfficiency,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _launchRsiTest(context, l);
              },
            ),
            // Asymmetry Test Option
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.brand.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.compare_arrows, color: AppColors.brand),
              ),
              title: Text(
                l.asymmetricTest,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                l.singleLegCmj,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _launchAsymmetryTest(context, l);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showAddAthleteToGroup() async {
    final activeGroup = ref.read(activeGroupProvider);
    if (activeGroup == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please select a group first')));
      return;
    }
    final athlete = await showDialog<Athlete>(
      context: context,
      builder: (_) => AddAthleteDialog(group: activeGroup),
    );
    if (athlete != null && mounted) {
      ref.read(activeAthleteProvider.notifier).state = athlete;
    }
  }
}
