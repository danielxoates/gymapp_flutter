import 'package:flutter/material.dart';
import '../theme.dart';
import '../components/ui.dart';
import '../data/exercises.dart';
import '../data/storage.dart';

class ExercisesScreen extends StatefulWidget {
  const ExercisesScreen({super.key});

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  List<Exercise> customExercises = [];
  String selectedMuscle = 'All';
  String selectedCategory = 'All';
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // New exercise form
  String newName = '';
  String newMuscle = 'Chest';
  String newCategory = 'Barbell';

  @override
  void initState() {
    super.initState();
    _loadCustom();
  }

  Future<void> _loadCustom() async {
    final data = await getCustomExercises();
    if (mounted) setState(() => customExercises = data);
  }

  List<Exercise> get allExercises => [...builtinExercises, ...customExercises];

  List<Exercise> get filtered => allExercises.where((e) {
        if (selectedMuscle != 'All' && e.muscle != selectedMuscle) return false;
        if (selectedCategory != 'All' && e.category != selectedCategory) {
          return false;
        }
        if (searchQuery.isNotEmpty &&
            !e.name.toLowerCase().contains(searchQuery.toLowerCase())) {
          return false;
        }
        return true;
      }).toList();

  Future<void> _handleAdd() async {
    if (newName.trim().isEmpty) {
      _showAlert('Error', 'Please enter an exercise name');
      return;
    }
    final exercise = Exercise(
      id: 'custom-${DateTime.now().millisecondsSinceEpoch}',
      name: newName.trim(),
      muscle: newMuscle,
      category: newCategory,
      icon: Icons.create_outlined,
      custom: true,
    );
    await addCustomExercise(exercise);
    setState(() {
      customExercises = [...customExercises, exercise];
      newName = '';
    });
    if (mounted) Navigator.of(context).pop();
  }

  void _handleDelete(Exercise exercise) {
    if (!exercise.custom) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        title: const Text('Delete Exercise',
            style: TextStyle(color: AppTheme.text)),
        content: Text('Remove "${exercise.name}"?',
            style: const TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final updated = await deleteCustomExercise(exercise.id);
              setState(() => customExercises = updated);
            },
            child: const Text('Delete',
                style: TextStyle(color: AppTheme.danger)),
          ),
        ],
      ),
    );
  }

  void _showAlert(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        title: Text(title, style: const TextStyle(color: AppTheme.text)),
        content: Text(message,
            style: const TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAddModal() {
    newName = '';
    newMuscle = 'Chest';
    newCategory = 'Barbell';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          decoration: const BoxDecoration(
            color: AppTheme.bgCard,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppTheme.radiusXl),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              AppTheme.spacingLg,
              AppTheme.spacingLg,
              AppTheme.spacingLg,
              MediaQuery.of(ctx).viewInsets.bottom + AppTheme.spacingXxl,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Add Custom Exercise',
                        style: TextStyle(
                          color: AppTheme.text,
                          fontSize: AppTheme.fontXl,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(ctx),
                        child: const Icon(Icons.close,
                            size: 24, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingLg),
                  AppInput(
                    label: 'Exercise Name',
                    placeholder: 'e.g. Zercher Squat',
                    onChanged: (v) {
                      newName = v;
                    },
                  ),
                  const SectionHeader(title: 'Muscle Group'),
                  Wrap(
                    children: muscleGroups
                        .where((m) => m != 'All')
                        .map((m) => AppChip(
                              label: m,
                              color: muscleColors[m],
                              selected: newMuscle == m,
                              onTap: () => setModalState(() => newMuscle = m),
                            ))
                        .toList(),
                  ),
                  const SectionHeader(title: 'Category'),
                  Wrap(
                    children: categories
                        .where((c) => c != 'All')
                        .map((c) => AppChip(
                              label: c,
                              selected: newCategory == c,
                              onTap: () =>
                                  setModalState(() => newCategory = c),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 20),
                  AppButton(
                    title: 'Add Exercise',
                    icon: Icons.add_circle_outline,
                    onPressed: _handleAdd,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final exerciseList = filtered;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top + AppTheme.spacingXl),

          // Search
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
            child: Row(
              children: [
                const Icon(Icons.search_outlined,
                    size: 18, color: AppTheme.textMuted),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => searchQuery = v),
                    style: const TextStyle(
                      color: AppTheme.text,
                      fontSize: AppTheme.fontMd,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search exercises…',
                      hintStyle:
                          const TextStyle(color: AppTheme.textMuted),
                      filled: true,
                      fillColor: AppTheme.bgInput,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMd),
                        borderSide:
                            const BorderSide(color: AppTheme.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMd),
                        borderSide:
                            const BorderSide(color: AppTheme.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMd),
                        borderSide:
                            const BorderSide(color: AppTheme.primary),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Muscle group filter
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingMd),
              children: muscleGroups
                  .map((m) => AppChip(
                        label: m,
                        color: muscleColors[m],
                        selected: selectedMuscle == m,
                        onTap: () =>
                            setState(() => selectedMuscle = m),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 4),

          // Category filter
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingMd),
              children: categories
                  .map((c) => AppChip(
                        label: c,
                        selected: selectedCategory == c,
                        onTap: () =>
                            setState(() => selectedCategory = c),
                      ))
                  .toList(),
            ),
          ),

          // Count
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppTheme.spacingMd, 8, AppTheme.spacingMd, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${exerciseList.length} exercises',
                style: const TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: AppTheme.fontXs,
                ),
              ),
            ),
          ),

          // Exercise list
          Expanded(
            child: exerciseList.isEmpty
                ? const EmptyState(
                    icon: Icons.search_outlined,
                    title: 'No exercises found',
                    subtitle: 'Try different filters',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                        AppTheme.spacingMd, 8, AppTheme.spacingMd, 100),
                    itemCount: exerciseList.length,
                    itemBuilder: (context, index) {
                      final item = exerciseList[index];
                      final color =
                          muscleColors[item.muscle] ?? AppTheme.primary;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: AppCard(
                          onTap: item.custom
                              ? () => _handleDelete(item)
                              : null,
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: color.withAlpha(32),
                                  borderRadius: BorderRadius.circular(
                                      AppTheme.radiusMd),
                                ),
                                child: Icon(item.icon,
                                    size: 20, color: color),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
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
                                      '${item.muscle} · ${item.category}${item.custom ? ' · Custom' : ''}',
                                      style: const TextStyle(
                                        color: AppTheme.textMuted,
                                        fontSize: AppTheme.fontXs,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (item.custom)
                                const Icon(Icons.delete_outline,
                                    size: 18, color: AppTheme.danger),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primary,
        onPressed: _showAddModal,
        child: const Icon(Icons.add, size: 28, color: Colors.white),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
