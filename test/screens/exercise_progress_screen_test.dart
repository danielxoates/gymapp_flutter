import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/screens/exercise_progress_screen.dart';
import 'package:gym_tracker/data/exercises.dart';
import 'package:gym_tracker/data/storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ExerciseProgressScreen Widget Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('displays loading indicator initially', (WidgetTester tester) async {
      const exercise = Exercise(
        id: 'bench-press',
        name: 'Bench Press',
        muscle: 'Chest',
        category: 'Barbell',
        icon: Icons.fitness_center,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: ExerciseProgressScreen(exercise: exercise),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays empty state when no workout data exists', (WidgetTester tester) async {
      const exercise = Exercise(
        id: 'bench-press',
        name: 'Bench Press',
        muscle: 'Chest',
        category: 'Barbell',
        icon: Icons.fitness_center,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: ExerciseProgressScreen(exercise: exercise),
        ),
      );

      // Wait for loading to complete
      await tester.pumpAndSettle();

      expect(find.text('No data yet'), findsOneWidget);
      expect(find.text('Complete a workout with this exercise\nto see your progress'), findsOneWidget);
      expect(find.byIcon(Icons.show_chart), findsOneWidget);
    });

    testWidgets('displays exercise name in app bar', (WidgetTester tester) async {
      const exercise = Exercise(
        id: 'bench-press',
        name: 'Bench Press',
        muscle: 'Chest',
        category: 'Barbell',
        icon: Icons.fitness_center,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: ExerciseProgressScreen(exercise: exercise),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Bench Press'), findsOneWidget);
    });

    testWidgets('back button pops navigation', (WidgetTester tester) async {
      const exercise = Exercise(
        id: 'bench-press',
        name: 'Bench Press',
        muscle: 'Chest',
        category: 'Barbell',
        icon: Icons.fitness_center,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ExerciseProgressScreen(exercise: exercise),
                  ),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('No data yet'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.text('No data yet'), findsNothing);
      expect(find.text('Open'), findsOneWidget);
    });

    testWidgets('displays stats cards with workout data', (WidgetTester tester) async {
      const exercise = Exercise(
        id: 'bench-press',
        name: 'Bench Press',
        muscle: 'Chest',
        category: 'Barbell',
        icon: Icons.fitness_center,
      );

      // Create test workout data
      final workout = Workout(
        id: 'workout-1',
        date: '2026-02-20T10:00:00.000Z',
        name: 'Chest Day',
        duration: 3600,
        exercises: [
          WorkoutExercise(
            exerciseId: 'bench-press',
            name: 'Bench Press',
            muscle: 'Chest',
            sets: [
              WorkoutSet(weight: '60', reps: '10'),
              WorkoutSet(weight: '70', reps: '8'),
              WorkoutSet(weight: '80', reps: '6'),
            ],
          ),
        ],
      );

      await saveWorkout(workout);

      await tester.pumpWidget(
        const MaterialApp(
          home: ExerciseProgressScreen(exercise: exercise),
        ),
      );

      await tester.pumpAndSettle();

      // Verify stat cards are displayed
      expect(find.text('Personal Best'), findsOneWidget);
      expect(find.text('80.0 kg'), findsWidgets); // May appear in multiple places
      
      expect(find.text('Total Volume'), findsWidgets); // Appears in stats and history
      expect(find.text('1.6k kg'), findsOneWidget); // 1640 kg total
      
      expect(find.text('Total Sets'), findsOneWidget);
      expect(find.text('3'), findsWidgets);
      
      expect(find.text('Workouts'), findsOneWidget);
      expect(find.text('1'), findsWidgets);
      
      expect(find.text('Avg Weight'), findsOneWidget);
      expect(find.text('70.0 kg'), findsWidgets);
      
      expect(find.text('Avg Reps'), findsOneWidget);
      expect(find.text('8.0'), findsOneWidget);
    });

    testWidgets('displays metric selector chips', (WidgetTester tester) async {
      const exercise = Exercise(
        id: 'bench-press',
        name: 'Bench Press',
        muscle: 'Chest',
        category: 'Barbell',
        icon: Icons.fitness_center,
      );

      // Create test workout data
      final workout = Workout(
        id: 'workout-1',
        date: '2026-02-20T10:00:00.000Z',
        name: 'Chest Day',
        duration: 3600,
        exercises: [
          WorkoutExercise(
            exerciseId: 'bench-press',
            name: 'Bench Press',
            muscle: 'Chest',
            sets: [
              WorkoutSet(weight: '60', reps: '10'),
            ],
          ),
        ],
      );

      await saveWorkout(workout);

      await tester.pumpWidget(
        const MaterialApp(
          home: ExerciseProgressScreen(exercise: exercise),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Max Weight'), findsOneWidget);
      expect(find.text('Volume'), findsWidgets); // Appears in chip and history
      expect(find.text('Total Reps'), findsOneWidget);
      expect(find.text('1RM Est.'), findsOneWidget);
    });

    testWidgets('tapping metric chips changes selection', (WidgetTester tester) async {
      const exercise = Exercise(
        id: 'bench-press',
        name: 'Bench Press',
        muscle: 'Chest',
        category: 'Barbell',
        icon: Icons.fitness_center,
      );

      // Create test workout data
      final workout = Workout(
        id: 'workout-1',
        date: '2026-02-20T10:00:00.000Z',
        name: 'Chest Day',
        duration: 3600,
        exercises: [
          WorkoutExercise(
            exerciseId: 'bench-press',
            name: 'Bench Press',
            muscle: 'Chest',
            sets: [
              WorkoutSet(weight: '60', reps: '10'),
              WorkoutSet(weight: '70', reps: '8'),
            ],
          ),
        ],
      );

      await saveWorkout(workout);

      await tester.pumpWidget(
        const MaterialApp(
          home: ExerciseProgressScreen(exercise: exercise),
        ),
      );

      await tester.pumpAndSettle();

      // Initially 'Max Weight' should be selected (default)
      // Find the Volume chip and tap it (use first to avoid ambiguity)
      await tester.tap(find.text('Volume').first);
      await tester.pumpAndSettle();

      // Chart should update (we can't easily test the chart rendering, 
      // but we can verify no errors occurred)
      expect(tester.takeException(), isNull);

      // Tap another metric
      await tester.tap(find.text('Total Reps'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('displays history section with workout details', (WidgetTester tester) async {
      const exercise = Exercise(
        id: 'bench-press',
        name: 'Bench Press',
        muscle: 'Chest',
        category: 'Barbell',
        icon: Icons.fitness_center,
      );

      // Create test workout data
      final workout = Workout(
        id: 'workout-1',
        date: '2026-02-20T10:00:00.000Z',
        name: 'Chest Day',
        duration: 3600,
        exercises: [
          WorkoutExercise(
            exerciseId: 'bench-press',
            name: 'Bench Press',
            muscle: 'Chest',
            sets: [
              WorkoutSet(weight: '60', reps: '10'),
              WorkoutSet(weight: '70', reps: '8'),
            ],
          ),
        ],
      );

      await saveWorkout(workout);

      await tester.pumpWidget(
        const MaterialApp(
          home: ExerciseProgressScreen(exercise: exercise),
        ),
      );

      await tester.pumpAndSettle();

      // Verify history section
      expect(find.text('History'), findsOneWidget);
      expect(find.text('Chest Day'), findsOneWidget);
      expect(find.text('2 sets'), findsOneWidget);
      
      // Check individual set displays (they include set number like "1: 60kg × 10")
      expect(find.textContaining('60'), findsWidgets);
      expect(find.textContaining('70'), findsWidgets);
    });

    testWidgets('displays multiple workout sessions in history', (WidgetTester tester) async {
      const exercise = Exercise(
        id: 'bench-press',
        name: 'Bench Press',
        muscle: 'Chest',
        category: 'Barbell',
        icon: Icons.fitness_center,
      );

      // Create multiple workouts
      final workout1 = Workout(
        id: 'workout-1',
        date: '2026-02-15T10:00:00.000Z',
        name: 'Chest Day 1',
        duration: 3600,
        exercises: [
          WorkoutExercise(
            exerciseId: 'bench-press',
            name: 'Bench Press',
            muscle: 'Chest',
            sets: [
              WorkoutSet(weight: '60', reps: '10'),
            ],
          ),
        ],
      );

      final workout2 = Workout(
        id: 'workout-2',
        date: '2026-02-20T10:00:00.000Z',
        name: 'Chest Day 2',
        duration: 3600,
        exercises: [
          WorkoutExercise(
            exerciseId: 'bench-press',
            name: 'Bench Press',
            muscle: 'Chest',
            sets: [
              WorkoutSet(weight: '70', reps: '10'),
            ],
          ),
        ],
      );

      await saveWorkout(workout1);
      await saveWorkout(workout2);

      await tester.pumpWidget(
        const MaterialApp(
          home: ExerciseProgressScreen(exercise: exercise),
        ),
      );

      await tester.pumpAndSettle();

      // Both workouts should appear in history
      expect(find.text('Chest Day 1'), findsOneWidget);
      expect(find.text('Chest Day 2'), findsOneWidget);
    });

    testWidgets('chart displays without errors with valid data', (WidgetTester tester) async {
      const exercise = Exercise(
        id: 'bench-press',
        name: 'Bench Press',
        muscle: 'Chest',
        category: 'Barbell',
        icon: Icons.fitness_center,
      );

      // Create test workout data with progression
      final workout1 = Workout(
        id: 'workout-1',
        date: '2026-02-10T10:00:00.000Z',
        name: 'Week 1',
        duration: 3600,
        exercises: [
          WorkoutExercise(
            exerciseId: 'bench-press',
            name: 'Bench Press',
            muscle: 'Chest',
            sets: [
              WorkoutSet(weight: '60', reps: '10'),
            ],
          ),
        ],
      );

      final workout2 = Workout(
        id: 'workout-2',
        date: '2026-02-17T10:00:00.000Z',
        name: 'Week 2',
        duration: 3600,
        exercises: [
          WorkoutExercise(
            exerciseId: 'bench-press',
            name: 'Bench Press',
            muscle: 'Chest',
            sets: [
              WorkoutSet(weight: '65', reps: '10'),
            ],
          ),
        ],
      );

      final workout3 = Workout(
        id: 'workout-3',
        date: '2026-02-24T10:00:00.000Z',
        name: 'Week 3',
        duration: 3600,
        exercises: [
          WorkoutExercise(
            exerciseId: 'bench-press',
            name: 'Bench Press',
            muscle: 'Chest',
            sets: [
              WorkoutSet(weight: '70', reps: '10'),
            ],
          ),
        ],
      );

      await saveWorkout(workout1);
      await saveWorkout(workout2);
      await saveWorkout(workout3);

      await tester.pumpWidget(
        const MaterialApp(
          home: ExerciseProgressScreen(exercise: exercise),
        ),
      );

      await tester.pumpAndSettle();

      // Verify chart section is rendered
      expect(find.text('Progress Over Time'), findsOneWidget);
      
      // No errors should occur during rendering
      expect(tester.takeException(), isNull);
    });

    testWidgets('scrolling works correctly with long history', (WidgetTester tester) async {
      const exercise = Exercise(
        id: 'bench-press',
        name: 'Bench Press',
        muscle: 'Chest',
        category: 'Barbell',
        icon: Icons.fitness_center,
      );

      // Create many workouts
      for (int i = 1; i <= 10; i++) {
        final workout = Workout(
          id: 'workout-$i',
          date: '2026-02-${i.toString().padLeft(2, '0')}T10:00:00.000Z',
          name: 'Day $i',
          duration: 3600,
          exercises: [
            WorkoutExercise(
              exerciseId: 'bench-press',
              name: 'Bench Press',
              muscle: 'Chest',
              sets: [
                WorkoutSet(weight: '${50 + i * 2}', reps: '10'),
              ],
            ),
          ],
        );
        await saveWorkout(workout);
      }

      await tester.pumpWidget(
        const MaterialApp(
          home: ExerciseProgressScreen(exercise: exercise),
        ),
      );

      await tester.pumpAndSettle();

      // Verify we can scroll (there are multiple scroll views)
      expect(find.byType(SingleChildScrollView), findsWidgets);
      
      // Scroll down the main content
      await tester.drag(find.byType(SingleChildScrollView).first, const Offset(0, -500));
      await tester.pumpAndSettle();
      
      // No errors should occur
      expect(tester.takeException(), isNull);
    });
  });
}
