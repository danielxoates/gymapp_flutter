import 'package:flutter/material.dart';
import '../theme.dart';
import '../components/ui.dart';
import '../data/storage.dart';
import '../data/exercises.dart';

class DashboardScreen extends StatefulWidget {
  final Function(int)? onNavigate;
  const DashboardScreen({super.key, this.onNavigate});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Stats? stats;
  bool loading = true;
  bool refreshing = false;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => loading = true);
    try {
      final data = await getStats();
      if (mounted) setState(() => stats = data);
    } catch (_) {
      if (mounted) {
        setState(() => stats = Stats(
              totalWorkouts: 0,
              weekWorkouts: 0,
              totalSets: 0,
              totalVolume: 0,
              streak: 0,
              muscleDistribution: {},
              personalRecords: {},
              recentWorkouts: [],
            ));
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _onRefresh() async {
    setState(() => refreshing = true);
    await _loadStats();
    if (mounted) setState(() => refreshing = false);
  }

  String _formatVolume(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    if (stats == null || loading) {
      return const Scaffold(
        backgroundColor: AppTheme.bg,
        body: Center(
          child: Text(
            'Loading…',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: AppTheme.fontMd,
            ),
          ),
        ),
      );
    }

    final muscleEntries = stats!.muscleDistribution.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxMuscleSets =
        muscleEntries.isNotEmpty ? muscleEntries.first.value : 1;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppTheme.primary,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppTheme.spacingMd,
            AppTheme.spacingXl,
            AppTheme.spacingMd,
            40,
          ),
          children: [
            // Safe area top padding
            SizedBox(height: MediaQuery.of(context).padding.top),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_greeting()} 💪',
                      style: const TextStyle(
                        color: AppTheme.text,
                        fontSize: AppTheme.fontXxl,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Here's your training overview",
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: AppTheme.fontSm,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.warning.withAlpha(21),
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.local_fire_department,
                          size: 20, color: AppTheme.warning),
                      const SizedBox(width: 4),
                      Text(
                        '${stats!.streak}',
                        style: const TextStyle(
                          color: AppTheme.warning,
                          fontWeight: FontWeight.w700,
                          fontSize: AppTheme.fontLg,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppTheme.spacingLg),

            // Quick stats row
            SizedBox(
              height: 145,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  StatCard(
                    icon: Icons.fitness_center_outlined,
                    iconColor: AppTheme.primary,
                    label: 'Workouts',
                    value: '${stats!.totalWorkouts}',
                    subtitle: 'Total',
                  ),
                  const SizedBox(width: 12),
                  StatCard(
                    icon: Icons.calendar_today_outlined,
                    iconColor: AppTheme.info,
                    label: 'This Week',
                    value: '${stats!.weekWorkouts}',
                    subtitle: 'of 7 days',
                  ),
                  const SizedBox(width: 12),
                  StatCard(
                    icon: Icons.layers_outlined,
                    iconColor: AppTheme.success,
                    label: 'Total Sets',
                    value: '${stats!.totalSets}',
                  ),
                  const SizedBox(width: 12),
                  StatCard(
                    icon: Icons.trending_up_outlined,
                    iconColor: AppTheme.warning,
                    label: 'Volume',
                    value: _formatVolume(stats!.totalVolume),
                    subtitle: 'kg lifted',
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.spacingLg),

            // Start new workout button
            AppButton(
              title: 'Start New Workout',
              icon: Icons.add_circle_outline,
              onPressed: () => widget.onNavigate?.call(2),
            ),

            // Muscle distribution
            const SectionHeader(title: 'Muscle Focus'),
            if (muscleEntries.isEmpty)
              const EmptyState(
                icon: Icons.accessibility_new_outlined,
                title: 'No data yet',
                subtitle: 'Complete your first workout!',
              )
            else
              AppCard(
                child: Column(
                  children: muscleEntries
                      .map((entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 80,
                                  child: Text(
                                    entry.key,
                                    style: const TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: AppTheme.fontSm,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 8,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    decoration: BoxDecoration(
                                      color: AppTheme.bgInput,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: FractionallySizedBox(
                                      alignment: Alignment.centerLeft,
                                      widthFactor:
                                          entry.value / maxMuscleSets,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: muscleColors[entry.key] ??
                                              AppTheme.primary,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 30,
                                  child: Text(
                                    '${entry.value}',
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                      color: AppTheme.textMuted,
                                      fontSize: AppTheme.fontXs,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),

            // Recent workouts
            SectionHeader(
              title: 'Recent Workouts',
              actionText: stats!.recentWorkouts.isNotEmpty ? 'See All' : null,
              onAction: () => widget.onNavigate?.call(3),
            ),
            if (stats!.recentWorkouts.isEmpty)
              const EmptyState(
                icon: Icons.description_outlined,
                title: 'No workouts logged',
                subtitle: "Tap 'Start New Workout' above",
              )
            else
              ...stats!.recentWorkouts.map((w) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    w.name.isEmpty ? 'Workout' : w.name,
                                    style: const TextStyle(
                                      color: AppTheme.text,
                                      fontSize: AppTheme.fontMd,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _formatDate(w.date),
                                    style: const TextStyle(
                                      color: AppTheme.textMuted,
                                      fontSize: AppTheme.fontXs,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.access_time_outlined,
                                      size: 14, color: AppTheme.textMuted),
                                  const SizedBox(width: 4),
                                  Text(
                                    w.duration > 0
                                        ? '${(w.duration / 60).round()} min'
                                        : '--',
                                    style: const TextStyle(
                                      color: AppTheme.textMuted,
                                      fontSize: AppTheme.fontXs,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ...w.exercises.take(3).map((e) => Padding(
                                padding: const EdgeInsets.only(bottom: 2),
                                child: Text(
                                  '${e.name} · ${e.sets.length} sets',
                                  style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: AppTheme.fontSm,
                                  ),
                                ),
                              )),
                          if (w.exercises.length > 3)
                            Text(
                              '+${w.exercises.length - 3} more',
                              style: const TextStyle(
                                color: AppTheme.primary,
                                fontSize: AppTheme.fontXs,
                              ),
                            ),
                        ],
                      ),
                    ),
                  )),

            // Personal records
            if (stats!.personalRecords.isNotEmpty) ...[
              const SectionHeader(title: 'Personal Records 🏆'),
              SizedBox(
                height: 110,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: (stats!.personalRecords.values.toList()
                        ..sort((a, b) => b.weight.compareTo(a.weight)))
                      .take(6)
                      .map((pr) => Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: AppCard(
                              child: SizedBox(
                                width: 90,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      pr.name,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontSize: AppTheme.fontXs,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${pr.weight.toStringAsFixed(pr.weight == pr.weight.roundToDouble() ? 0 : 1)} kg',
                                      style: const TextStyle(
                                        color: AppTheme.warning,
                                        fontSize: AppTheme.fontXl,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    Text(
                                      'x${pr.reps}',
                                      style: const TextStyle(
                                        color: AppTheme.textMuted,
                                        fontSize: AppTheme.fontSm,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(String isoDate) {
    try {
      final d = DateTime.parse(isoDate);
      const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${weekdays[d.weekday - 1]}, ${d.day} ${months[d.month - 1]}';
    } catch (_) {
      return '';
    }
  }
}
