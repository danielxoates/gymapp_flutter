import 'dart:async';
import 'package:flutter/material.dart';
import '../theme.dart';
import '../components/ui.dart';
import '../data/exercises.dart';
import '../data/storage.dart';

class WorkoutScreen extends StatefulWidget {
  final Workout? existingWorkout;

  const WorkoutScreen({super.key, this.existingWorkout});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  bool isActive = false;
  String workoutName = '';
  List<WorkoutExercise> exercises = [];
  List<Exercise> customExercises = [];
  String pickerFilter = 'All';
  Map<String, WorkoutExercise> previousData = {};

  Timer? _timer;
  int elapsed = 0;
  DateTime? _startTime;

  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadExercises();

    // If editing an existing workout, pre-populate data
    if (widget.existingWorkout != null) {
      isActive = true;
      workoutName = widget.existingWorkout!.name;
      _nameController.text = widget.existingWorkout!.name;
      exercises = widget.existingWorkout!.exercises;
      elapsed = widget.existingWorkout!.duration;
      _startTimer();
      for (final ex in exercises) {
        _loadPreviousData(ex.exerciseId);
      }
    }
  }

  Future<void> _loadExercises() async {
    final data = await getCustomExercises();
    if (mounted) {
      setState(() => customExercises = data);
    }
  }

    List<Exercise> get allExercises {
    final combined = [...builtinExercises, ...customExercises];

    // Sort by muscle group (using muscleGroups order), then category, then name
    combined.sort((a, b) {
      final ia = muscleGroups.indexOf(a.muscle);
      final ib = muscleGroups.indexOf(b.muscle);
      final ja = ia == -1 ? muscleGroups.length : ia;
      final jb = ib == -1 ? muscleGroups.length : ib;
      if (ja != jb) return ja.compareTo(jb);
      final catCmp = a.category.compareTo(b.category);
      if (catCmp != 0) return catCmp;
      return a.name.compareTo(b.name);
    });

    return combined;
  }

  void _startTimer() {
    _startTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_startTime != null && mounted) {
        setState(() {
          elapsed = DateTime.now().difference(_startTime!).inSeconds;
        });
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  String _formatTime(int sec) {
    final m = (sec ~/ 60).toString().padLeft(2, '0');
    final s = (sec % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _handleStart() {
    setState(() {
      isActive = true;
      exercises = [];
      workoutName = '';
      _nameController.clear();
      elapsed = 0;
    });
    _startTimer();
  }

  void _handleFinish() {
    if (exercises.isEmpty) {
      _showAlert('Empty Workout', 'Add at least one exercise before saving.');
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        title: const Text(
          'Finish Workout',
          style: TextStyle(color: AppTheme.text),
        ),
        content: const Text(
          'Save this workout?',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Continue'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              _stopTimer();

              // Check if we're editing or creating new
              final isEditing = widget.existingWorkout != null;
              final workout = Workout(
                id: isEditing
                    ? widget.existingWorkout!.id
                    : DateTime.now().millisecondsSinceEpoch.toString(),
                date: isEditing
                    ? widget.existingWorkout!.date
                    : DateTime.now().toIso8601String(),
                name: workoutName.isEmpty ? 'Workout' : workoutName,
                duration: elapsed,
                exercises: exercises
                    .map(
                      (e) => WorkoutExercise(
                        exerciseId: e.exerciseId,
                        name: e.name,
                        muscle: e.muscle,
                        sets: e.sets
                            .where(
                              (s) => s.weight.isNotEmpty || s.reps.isNotEmpty,
                            )
                            .toList(),
                      ),
                    )
                    .toList(),
              );

              if (isEditing) {
                await updateWorkout(workout);
              } else {
                await saveWorkout(workout);
              }

              if (mounted) {
                setState(() {
                  isActive = false;
                  exercises = [];
                });
                _showAlert(
                  'Saved! 🎉',
                  isEditing
                      ? 'Workout updated successfully.'
                      : 'Workout logged successfully.',
                );
              }
            },
            child: const Text(
              'Save',
              style: TextStyle(color: AppTheme.success),
            ),
          ),
        ],
      ),
    );
  }

  void _handleCancel() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        title: const Text(
          'Discard Workout?',
          style: TextStyle(color: AppTheme.text),
        ),
        content: const Text(
          'All progress will be lost.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep Going'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _stopTimer();
              setState(() {
                isActive = false;
                exercises = [];
              });
            },
            child: const Text(
              'Discard',
              style: TextStyle(color: AppTheme.danger),
            ),
          ),
        ],
      ),
    );
  }

  void _addExerciseToWorkout(Exercise exercise) {
    setState(() {
      exercises.add(
        WorkoutExercise(
          exerciseId: exercise.id,
          name: exercise.name,
          muscle: exercise.muscle,
          sets: [WorkoutSet(weight: '', reps: '')],
        ),
      );
    });
    _loadPreviousData(exercise.id);
    Navigator.pop(context);
  }

  Future<void> _loadPreviousData(String exerciseId) async {
    if (previousData.containsKey(exerciseId)) return;
    final last = await getLastExerciseData(
      exerciseId,
      excludeWorkoutId: widget.existingWorkout?.id,
    );
    if (last != null && mounted) {
      setState(() {
        previousData[exerciseId] = last;
      });
    }
  }

  void _removeExercise(int index) {
    setState(() {
      exercises.removeAt(index);
    });
  }

  void _addSet(int exerciseIndex) {
    setState(() {
      final lastSet = exercises[exerciseIndex].sets.isNotEmpty
          ? exercises[exerciseIndex].sets.last
          : null;
      exercises[exerciseIndex].sets.add(
        WorkoutSet(weight: lastSet?.weight ?? '', reps: lastSet?.reps ?? ''),
      );
    });
  }

  void _removeSet(int exerciseIndex, int setIndex) {
    if (exercises[exerciseIndex].sets.length <= 1) return;
    setState(() {
      exercises[exerciseIndex].sets.removeAt(setIndex);
    });
  }

  void _updateSet(int exerciseIndex, int setIndex, String field, String value) {
    setState(() {
      if (field == 'weight') {
        exercises[exerciseIndex].sets[setIndex].weight = value;
      } else {
        exercises[exerciseIndex].sets[setIndex].reps = value;
      }
    });
  }

  void _showAlert(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        title: Text(title, style: const TextStyle(color: AppTheme.text)),
        content: Text(
          message,
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showExercisePicker() {
    pickerFilter = 'All';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final pickerExercises = pickerFilter == 'All'
              ? allExercises
              : allExercises
                    .where((e) => e.muscle == pickerFilter)
                    .toList();

          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            decoration: const BoxDecoration(
              color: AppTheme.bgCard,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppTheme.radiusXl),
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingLg),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Add Exercise',
                        style: TextStyle(
                          color: AppTheme.text,
                          fontSize: AppTheme.fontXl,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(ctx),
                        child: const Icon(
                          Icons.close,
                          size: 24,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingLg,
                    ),
                    children: muscleGroups
                        .map(
                          (m) => AppChip(
                            label: m,
                            color: muscleColors[m],
                            selected: pickerFilter == m,
                            onTap: () => setModalState(() => pickerFilter = m),
                          ),
                        )
                        .toList(),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingLg,
                    ),
                    itemCount: pickerExercises.length,
                    itemBuilder: (context, index) {
                      final item = pickerExercises[index];
                      final color =
                          muscleColors[item.muscle] ?? AppTheme.primary;
                      return GestureDetector(
                        onTap: () => _addExerciseToWorkout(item),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: AppTheme.divider),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(item.icon, size: 20, color: color),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: const TextStyle(
                                        color: AppTheme.text,
                                        fontSize: AppTheme.fontMd,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${item.muscle} · ${item.category}',
                                      style: const TextStyle(
                                        color: AppTheme.textMuted,
                                        fontSize: AppTheme.fontXs,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.add_circle,
                                size: 22,
                                color: AppTheme.primary,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ─── Inactive state ──────────────────────────────
    if (!isActive) {
      return Scaffold(
        backgroundColor: AppTheme.bg,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingXl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withAlpha(21),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.fitness_center,
                    size: 64,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingLg),
                const Text(
                  'Ready to Train?',
                  style: TextStyle(
                    color: AppTheme.text,
                    fontSize: AppTheme.fontXxl,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Track your sets, reps, and weights in real-time',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: AppTheme.fontMd,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingLg),
                SizedBox(
                  width: double.infinity,
                  child: AppButton(
                    title: 'Start Workout',
                    icon: Icons.play_circle_outline,
                    onPressed: _handleStart,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // ─── Active workout ──────────────────────────────
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top),

          // Top bar
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTheme.spacingMd,
              AppTheme.spacingXl,
              AppTheme.spacingMd,
              AppTheme.spacingSm,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: _handleCancel,
                  child: const Icon(
                    Icons.close,
                    size: 26,
                    color: AppTheme.danger,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.bgCard,
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.access_time_outlined,
                        size: 18,
                        color: AppTheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _formatTime(elapsed),
                        style: const TextStyle(
                          color: AppTheme.primary,
                          fontSize: AppTheme.fontLg,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: _handleFinish,
                  child: const Icon(
                    Icons.check_circle,
                    size: 30,
                    color: AppTheme.success,
                  ),
                ),
              ],
            ),
          ),

          // Workout name
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
            child: AppInput(
              placeholder: 'Workout name (e.g. Push Day)',
              controller: _nameController,
              onChanged: (v) => workoutName = v,
            ),
          ),
          const SizedBox(height: 8),

          // Exercises list
          Expanded(
            child: exercises.isEmpty
                ? const EmptyState(
                    icon: Icons.add_circle_outline,
                    title: 'No exercises yet',
                    subtitle: 'Tap the button below to add exercises',
                  )
                : ListView.builder(
                    padding: EdgeInsets.fromLTRB(
                      AppTheme.spacingMd,
                      0,
                      AppTheme.spacingMd,
                      120,
                    ),
                    itemCount: exercises.length,
                    itemBuilder: (context, ei) {
                      final ex = exercises[ei];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Exercise header
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          color:
                                              muscleColors[ex.muscle] ??
                                              AppTheme.primary,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        ex.name,
                                        style: const TextStyle(
                                          color: AppTheme.text,
                                          fontSize: AppTheme.fontMd,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  GestureDetector(
                                    onTap: () => _removeExercise(ei),
                                    child: const Icon(
                                      Icons.delete_outline,
                                      size: 18,
                                      color: AppTheme.danger,
                                    ),
                                  ),
                                ],
                              ),
                              // Previous session info
                              if (previousData.containsKey(ex.exerciseId))
                                Padding(
                                  padding: const EdgeInsets.only(top: 4, bottom: 6),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.history,
                                        size: 14,
                                        color: AppTheme.textMuted,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          'Last: ${previousData[ex.exerciseId]!.sets.map((s) => '${s.weight}kg × ${s.reps}').join(', ')}',
                                          style: const TextStyle(
                                            color: AppTheme.textMuted,
                                            fontSize: AppTheme.fontXs,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              const SizedBox(height: 10),

                              // Set headers
                              Row(
                                children: [
                                  const SizedBox(
                                    width: 40,
                                    child: Text(
                                      'SET',
                                      style: TextStyle(
                                        color: AppTheme.textMuted,
                                        fontSize: AppTheme.fontXs,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const Expanded(
                                    child: Text(
                                      'WEIGHT (KG)',
                                      style: TextStyle(
                                        color: AppTheme.textMuted,
                                        fontSize: AppTheme.fontXs,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const Expanded(
                                    child: Text(
                                      'REPS',
                                      style: TextStyle(
                                        color: AppTheme.textMuted,
                                        fontSize: AppTheme.fontXs,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 30),
                                ],
                              ),
                              const SizedBox(height: 6),

                              // Sets
                              ...List.generate(ex.sets.length, (si) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 32,
                                        height: 32,
                                        margin: const EdgeInsets.only(right: 8),
                                        decoration: BoxDecoration(
                                          color: AppTheme.bgInput,
                                          borderRadius: BorderRadius.circular(
                                            AppTheme.radiusSm,
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          '${si + 1}',
                                          style: const TextStyle(
                                            color: AppTheme.textSecondary,
                                            fontSize: AppTheme.fontSm,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: _SetInputField(
                                          value: ex.sets[si].weight,
                                          placeholder: '0',
                                          onChanged: (v) =>
                                              _updateSet(ei, si, 'weight', v),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: _SetInputField(
                                          value: ex.sets[si].reps,
                                          placeholder: '0',
                                          onChanged: (v) =>
                                              _updateSet(ei, si, 'reps', v),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 30,
                                        child: GestureDetector(
                                          onTap: () => _removeSet(ei, si),
                                          child: const Icon(
                                            Icons.remove_circle_outline,
                                            size: 20,
                                            color: AppTheme.textMuted,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),

                              // Add set button
                              Container(
                                margin: const EdgeInsets.only(top: 6),
                                padding: const EdgeInsets.only(top: 8),
                                decoration: const BoxDecoration(
                                  border: Border(
                                    top: BorderSide(color: AppTheme.divider),
                                  ),
                                ),
                                child: GestureDetector(
                                  onTap: () => _addSet(ei),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add,
                                        size: 16,
                                        color: AppTheme.primary,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Add Set',
                                        style: TextStyle(
                                          color: AppTheme.primary,
                                          fontSize: AppTheme.fontSm,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Bottom bar
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            decoration: const BoxDecoration(
              color: AppTheme.bgCard,
              border: Border(top: BorderSide(color: AppTheme.border)),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: AppButton(
                      title: 'Add Exercise',
                      icon: Icons.add_circle_outline,
                      isPrimary: false,
                      onPressed: _showExercisePicker,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppButton(
                      title: 'Finish',
                      icon: Icons.check_circle_outline,
                      onPressed: _handleFinish,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _stopTimer();
    _nameController.dispose();
    super.dispose();
  }
}

// Small helper widget for set input fields
class _SetInputField extends StatefulWidget {
  final String value;
  final String placeholder;
  final ValueChanged<String> onChanged;

  const _SetInputField({
    required this.value,
    required this.placeholder,
    required this.onChanged,
  });

  @override
  State<_SetInputField> createState() => _SetInputFieldState();
}

class _SetInputFieldState extends State<_SetInputField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(_SetInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _controller.text && widget.value != oldWidget.value) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: AppTheme.text, fontSize: AppTheme.fontMd),
      decoration: InputDecoration(
        hintText: widget.placeholder,
        hintStyle: const TextStyle(color: AppTheme.textMuted),
        filled: true,
        fillColor: AppTheme.bgInput,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        isDense: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: const BorderSide(color: AppTheme.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: const BorderSide(color: AppTheme.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: const BorderSide(color: AppTheme.primary),
        ),
      ),
    );
  }
}
