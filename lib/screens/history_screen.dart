import 'package:flutter/material.dart';
import '../theme.dart';
import '../components/ui.dart';
import '../data/storage.dart';
import '../data/exercises.dart';
import 'workout_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Workout> workouts = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await getWorkouts();
    if (mounted) setState(() => workouts = data);
  }

  void _handleDelete(Workout workout) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        title: const Text(
          'Delete Workout',
          style: TextStyle(color: AppTheme.text),
        ),
        content: Text(
          'Remove "${workout.name}"?',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final updated = await deleteWorkout(workout.id);
              setState(() => workouts = updated);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppTheme.danger),
            ),
          ),
        ],
      ),
    );
  }

  void _handleEdit(Workout workout) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkoutScreen(existingWorkout: workout),
      ),
    );
    // Reload workouts after returning from edit
    _load();
  }

  int _totalSets(Workout w) =>
      w.exercises.fold(0, (sum, e) => sum + e.sets.length);

  double _totalVolume(Workout w) => w.exercises.fold(0.0, (sum, e) {
    return sum +
        e.sets.fold(0.0, (s, set) {
          final weight = double.tryParse(set.weight) ?? 0;
          final reps = int.tryParse(set.reps) ?? 0;
          return s + (weight * reps);
        });
  });

  // Group workouts by month
  Map<String, List<Workout>> get grouped {
    final Map<String, List<Workout>> result = {};
    for (final w in workouts) {
      try {
        final d = DateTime.parse(w.date);
        const months = [
          'January',
          'February',
          'March',
          'April',
          'May',
          'June',
          'July',
          'August',
          'September',
          'October',
          'November',
          'December',
        ];
        final key = '${months[d.month - 1]} ${d.year}';
        result.putIfAbsent(key, () => []).add(w);
      } catch (_) {}
    }
    return result;
  }

  String _formatDate(String isoDate) {
    try {
      final d = DateTime.parse(isoDate);
      const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      final h = d.hour.toString().padLeft(2, '0');
      final m = d.minute.toString().padLeft(2, '0');
      return '${weekdays[d.weekday - 1]}, ${d.day} ${months[d.month - 1]}, $h:$m';
    } catch (_) {
      return '';
    }
  }

  String _formatVolume(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) {
      final formatted = (v / 1000).toStringAsFixed(1);
      return '${formatted}K';
    }
    return v.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    if (workouts.isEmpty) {
      return Scaffold(
        backgroundColor: AppTheme.bg,
        body: SafeArea(
          child: const EmptyState(
            icon: Icons.description_outlined,
            title: 'No workout history',
            subtitle: 'Complete your first workout to see it here',
          ),
        ),
      );
    }

    final sections = grouped.entries.toList();

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: ListView.builder(
        padding: EdgeInsets.fromLTRB(
          AppTheme.spacingMd,
          MediaQuery.of(context).padding.top + AppTheme.spacingXl,
          AppTheme.spacingMd,
          40,
        ),
        itemCount: sections.length,
        itemBuilder: (context, sectionIndex) {
          final section = sections[sectionIndex];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  top: AppTheme.spacingLg,
                  bottom: AppTheme.spacingSm,
                ),
                child: Text(
                  section.key,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: AppTheme.fontMd,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              ...section.value.map((workout) => _buildWorkoutCard(workout)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildWorkoutCard(Workout workout) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.only(right: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        workout.name,
                        style: const TextStyle(
                          color: AppTheme.text,
                          fontSize: AppTheme.fontLg,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatDate(workout.date),
                        style: const TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: AppTheme.fontXs,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Quick stats
                Container(
                  padding: const EdgeInsets.only(bottom: 10),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: AppTheme.divider)),
                  ),
                  child: Row(
                    children: [
                      _quickStat(
                        Icons.access_time_outlined,
                        workout.duration > 0
                            ? '${(workout.duration / 60).round()} min'
                            : '--',
                      ),
                      const SizedBox(width: 18),
                      _quickStat(
                        Icons.layers_outlined,
                        '${_totalSets(workout)} sets',
                      ),
                      const SizedBox(width: 18),
                      _quickStat(
                        Icons.trending_up_outlined,
                        '${_formatVolume(_totalVolume(workout))} kg',
                      ),
                    ],
                  ),
                ),

                // Exercises
                const SizedBox(height: 6),
                ...workout.exercises.map(
                  (ex) => Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: muscleColors[ex.muscle] ?? AppTheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            ex.name,
                            style: const TextStyle(
                              color: AppTheme.text,
                              fontSize: AppTheme.fontSm,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          ex.sets
                              .map(
                                (s) =>
                                    '${s.weight.isEmpty ? '0' : s.weight}×${s.reps.isEmpty ? '0' : s.reps}',
                              )
                              .join(', '),
                          style: const TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: AppTheme.fontXs,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Action buttons
            Positioned(
              top: 0,
              right: 0,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => _handleEdit(workout),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.edit_outlined,
                        size: 16,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _handleDelete(workout),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.delete_outline,
                        size: 16,
                        color: AppTheme.danger,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickStat(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppTheme.textMuted),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: AppTheme.fontSm,
          ),
        ),
      ],
    );
  }
}
