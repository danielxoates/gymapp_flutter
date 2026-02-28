import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/data/storage.dart';
import 'package:gym_tracker/data/exercises.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Exercise Progress Data Tests', () {
    setUp(() async {
      // Initialize shared preferences with empty data
      SharedPreferences.setMockInitialValues({});
    });

    test('getExerciseProgress returns empty data for exercise with no history', () async {
      final progress = await getExerciseProgress('bench-press');
      
      expect(progress.exerciseId, equals('bench-press'));
      expect(progress.sets, isEmpty);
      expect(progress.totalSets, equals(0));
      expect(progress.totalWorkouts, equals(0));
      expect(progress.maxWeight, equals(0));
      expect(progress.totalVolume, equals(0));
      expect(progress.avgWeight, equals(0));
      expect(progress.avgReps, equals(0));
      expect(progress.firstWorkout, isNull);
      expect(progress.lastWorkout, isNull);
    });

    test('getExerciseProgress calculates correct stats for single workout', () async {
      // Create a workout with exercise data
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
      
      final progress = await getExerciseProgress('bench-press');
      
      expect(progress.exerciseId, equals('bench-press'));
      expect(progress.exerciseName, equals('Bench Press'));
      expect(progress.sets.length, equals(3));
      expect(progress.totalSets, equals(3));
      expect(progress.totalWorkouts, equals(1));
      expect(progress.maxWeight, equals(80));
      
      // Total volume: (60*10) + (70*8) + (80*6) = 600 + 560 + 480 = 1640
      expect(progress.totalVolume, equals(1640));
      
      // Average weight: (60 + 70 + 80) / 3 = 70
      expect(progress.avgWeight, closeTo(70, 0.01));
      
      // Average reps: (10 + 8 + 6) / 3 = 8
      expect(progress.avgReps, closeTo(8, 0.01));
      
      expect(progress.firstWorkout, isNotNull);
      expect(progress.lastWorkout, isNotNull);
    });

    test('getExerciseProgress aggregates data from multiple workouts', () async {
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
              WorkoutSet(weight: '65', reps: '8'),
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
              WorkoutSet(weight: '75', reps: '8'),
              WorkoutSet(weight: '80', reps: '6'),
            ],
          ),
        ],
      );
      
      await saveWorkout(workout1);
      await saveWorkout(workout2);
      
      final progress = await getExerciseProgress('bench-press');
      
      expect(progress.totalSets, equals(5));
      expect(progress.totalWorkouts, equals(2));
      expect(progress.maxWeight, equals(80));
      
      // Total volume: (60*10) + (65*8) + (70*10) + (75*8) + (80*6)
      // = 600 + 520 + 700 + 600 + 480 = 2900
      expect(progress.totalVolume, equals(2900));
      
      expect(progress.firstWorkout?.year, equals(2026));
      expect(progress.firstWorkout?.month, equals(2));
      expect(progress.firstWorkout?.day, equals(15));
      
      expect(progress.lastWorkout?.day, equals(20));
    });

    test('getExerciseProgress ignores other exercises', () async {
      final workout = Workout(
        id: 'workout-1',
        date: '2026-02-20T10:00:00.000Z',
        name: 'Full Body',
        duration: 5400,
        exercises: [
          WorkoutExercise(
            exerciseId: 'bench-press',
            name: 'Bench Press',
            muscle: 'Chest',
            sets: [
              WorkoutSet(weight: '60', reps: '10'),
            ],
          ),
          WorkoutExercise(
            exerciseId: 'squat',
            name: 'Squat',
            muscle: 'Legs',
            sets: [
              WorkoutSet(weight: '100', reps: '10'),
              WorkoutSet(weight: '110', reps: '8'),
            ],
          ),
        ],
      );
      
      await saveWorkout(workout);
      
      final benchProgress = await getExerciseProgress('bench-press');
      expect(benchProgress.totalSets, equals(1));
      expect(benchProgress.maxWeight, equals(60));
      
      final squatProgress = await getExerciseProgress('squat');
      expect(squatProgress.totalSets, equals(2));
      expect(squatProgress.maxWeight, equals(110));
    });

    test('getExerciseProgress handles sets with zero weight/reps correctly', () async {
      final workout = Workout(
        id: 'workout-1',
        date: '2026-02-20T10:00:00.000Z',
        name: 'Test Workout',
        duration: 3600,
        exercises: [
          WorkoutExercise(
            exerciseId: 'bench-press',
            name: 'Bench Press',
            muscle: 'Chest',
            sets: [
              WorkoutSet(weight: '60', reps: '10'),
              WorkoutSet(weight: '', reps: ''), // Empty set
              WorkoutSet(weight: '0', reps: '0'), // Zero set
              WorkoutSet(weight: '70', reps: '8'),
            ],
          ),
        ],
      );
      
      await saveWorkout(workout);
      
      final progress = await getExerciseProgress('bench-press');
      
      // Should only count the two valid sets
      expect(progress.totalSets, equals(2));
      expect(progress.maxWeight, equals(70));
      expect(progress.avgWeight, equals(65));
    });

    test('getExerciseProgress maintains chronological order', () async {
      // Add workouts in non-chronological order
      final workout2 = Workout(
        id: 'workout-2',
        date: '2026-02-25T10:00:00.000Z',
        name: 'Later Workout',
        duration: 3600,
        exercises: [
          WorkoutExercise(
            exerciseId: 'bench-press',
            name: 'Bench Press',
            muscle: 'Chest',
            sets: [WorkoutSet(weight: '80', reps: '8')],
          ),
        ],
      );
      
      final workout1 = Workout(
        id: 'workout-1',
        date: '2026-02-20T10:00:00.000Z',
        name: 'Earlier Workout',
        duration: 3600,
        exercises: [
          WorkoutExercise(
            exerciseId: 'bench-press',
            name: 'Bench Press',
            muscle: 'Chest',
            sets: [WorkoutSet(weight: '70', reps: '10')],
          ),
        ],
      );
      
      await saveWorkout(workout2);
      await saveWorkout(workout1);
      
      final progress = await getExerciseProgress('bench-press');
      
      // First workout should be the earlier date
      expect(progress.firstWorkout?.day, equals(20));
      
      // Last workout should be the later date
      expect(progress.lastWorkout?.day, equals(25));
      
      // Sets are collected as workouts are processed
      // The function processes workouts in reverse order of storage
      // which may not be chronological by date
      expect(progress.sets.length, equals(2));
      expect(progress.sets.any((s) => s.weight == 70.0), isTrue);
      expect(progress.sets.any((s) => s.weight == 80.0), isTrue);
    });

    test('ExerciseSetData contains correct workout metadata', () async {
      final workout = Workout(
        id: 'workout-1',
        date: '2026-02-20T10:00:00.000Z',
        name: 'Push Day',
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
      
      final progress = await getExerciseProgress('bench-press');
      final setData = progress.sets.first;
      
      expect(setData.weight, equals(60));
      expect(setData.reps, equals(10));
      expect(setData.workoutName, equals('Push Day'));
      expect(setData.date.year, equals(2026));
      expect(setData.date.month, equals(2));
      expect(setData.date.day, equals(20));
    });
  });

  group('Workout Data Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    test('saveWorkout and getWorkouts work correctly', () async {
      final workout = Workout(
        id: 'workout-1',
        date: '2026-02-20T10:00:00.000Z',
        name: 'Test Workout',
        duration: 3600,
        exercises: [],
      );
      
      await saveWorkout(workout);
      final workouts = await getWorkouts();
      
      expect(workouts.length, equals(1));
      expect(workouts.first.id, equals('workout-1'));
      expect(workouts.first.name, equals('Test Workout'));
    });

    test('updateWorkout modifies existing workout', () async {
      final workout = Workout(
        id: 'workout-1',
        date: '2026-02-20T10:00:00.000Z',
        name: 'Original Name',
        duration: 3600,
        exercises: [],
      );
      
      await saveWorkout(workout);
      
      final updated = Workout(
        id: 'workout-1',
        date: '2026-02-20T10:00:00.000Z',
        name: 'Updated Name',
        duration: 7200,
        exercises: [],
      );
      
      await updateWorkout(updated);
      final workouts = await getWorkouts();
      
      expect(workouts.length, equals(1));
      expect(workouts.first.name, equals('Updated Name'));
      expect(workouts.first.duration, equals(7200));
    });

    test('deleteWorkout removes workout from storage', () async {
      final workout1 = Workout(
        id: 'workout-1',
        date: '2026-02-20T10:00:00.000Z',
        name: 'Workout 1',
        duration: 3600,
        exercises: [],
      );
      
      final workout2 = Workout(
        id: 'workout-2',
        date: '2026-02-21T10:00:00.000Z',
        name: 'Workout 2',
        duration: 3600,
        exercises: [],
      );
      
      await saveWorkout(workout1);
      await saveWorkout(workout2);
      
      await deleteWorkout('workout-1');
      final workouts = await getWorkouts();
      
      expect(workouts.length, equals(1));
      expect(workouts.first.id, equals('workout-2'));
    });

    test('getWorkouts returns empty list when no workouts exist', () async {
      final workouts = await getWorkouts();
      expect(workouts, isEmpty);
    });

    test('saveWorkout inserts newest first', () async {
      final w1 = Workout(
        id: 'w1', date: '2026-02-20T10:00:00.000Z',
        name: 'First', duration: 3600, exercises: [],
      );
      final w2 = Workout(
        id: 'w2', date: '2026-02-21T10:00:00.000Z',
        name: 'Second', duration: 3600, exercises: [],
      );

      await saveWorkout(w1);
      await saveWorkout(w2);
      final workouts = await getWorkouts();

      expect(workouts.first.id, equals('w2'));
      expect(workouts.last.id, equals('w1'));
    });

    test('saveWorkout returns updated list', () async {
      final w = Workout(
        id: 'w1', date: '2026-02-20T10:00:00.000Z',
        name: 'Test', duration: 3600, exercises: [],
      );
      final result = await saveWorkout(w);
      expect(result.length, equals(1));
      expect(result.first.id, equals('w1'));
    });

    test('updateWorkout is no-op for non-existent id', () async {
      final w = Workout(
        id: 'w1', date: '2026-02-20T10:00:00.000Z',
        name: 'Test', duration: 3600, exercises: [],
      );
      await saveWorkout(w);

      final ghost = Workout(
        id: 'non-existent', date: '2026-02-20T10:00:00.000Z',
        name: 'Ghost', duration: 0, exercises: [],
      );
      await updateWorkout(ghost);

      final workouts = await getWorkouts();
      expect(workouts.length, equals(1));
      expect(workouts.first.name, equals('Test'));
    });

    test('deleteWorkout with non-existent id leaves list unchanged', () async {
      final w = Workout(
        id: 'w1', date: '2026-02-20T10:00:00.000Z',
        name: 'Test', duration: 3600, exercises: [],
      );
      await saveWorkout(w);

      await deleteWorkout('non-existent');
      final workouts = await getWorkouts();
      expect(workouts.length, equals(1));
    });
  });

  group('Serialization Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    test('WorkoutSet round-trips through JSON', () {
      final set = WorkoutSet(weight: '80', reps: '10');
      final json = set.toJson();
      final restored = WorkoutSet.fromJson(json);

      expect(restored.weight, equals('80'));
      expect(restored.reps, equals('10'));
    });

    test('WorkoutSet.fromJson handles missing values', () {
      final set = WorkoutSet.fromJson({});
      expect(set.weight, equals(''));
      expect(set.reps, equals(''));
    });

    test('WorkoutExercise round-trips through JSON', () {
      final exercise = WorkoutExercise(
        exerciseId: 'bench-press',
        name: 'Bench Press',
        muscle: 'Chest',
        sets: [WorkoutSet(weight: '60', reps: '10')],
      );
      final json = exercise.toJson();
      final restored = WorkoutExercise.fromJson(json);

      expect(restored.exerciseId, equals('bench-press'));
      expect(restored.name, equals('Bench Press'));
      expect(restored.muscle, equals('Chest'));
      expect(restored.sets.length, equals(1));
      expect(restored.sets.first.weight, equals('60'));
    });

    test('WorkoutExercise.fromJson handles missing sets', () {
      final exercise = WorkoutExercise.fromJson({
        'exerciseId': 'test',
        'name': 'Test',
        'muscle': 'Test',
      });
      expect(exercise.sets, isEmpty);
    });

    test('Workout round-trips through JSON', () {
      final workout = Workout(
        id: 'w1',
        date: '2026-02-20T10:00:00.000Z',
        name: 'Push Day',
        duration: 3600,
        exercises: [
          WorkoutExercise(
            exerciseId: 'bench-press',
            name: 'Bench Press',
            muscle: 'Chest',
            sets: [WorkoutSet(weight: '80', reps: '8')],
          ),
        ],
      );
      final json = workout.toJson();
      final restored = Workout.fromJson(json);

      expect(restored.id, equals('w1'));
      expect(restored.date, equals('2026-02-20T10:00:00.000Z'));
      expect(restored.name, equals('Push Day'));
      expect(restored.duration, equals(3600));
      expect(restored.exercises.length, equals(1));
      expect(restored.exercises.first.exerciseId, equals('bench-press'));
    });

    test('Workout.fromJson handles missing values with defaults', () {
      final workout = Workout.fromJson({});
      expect(workout.id, equals(''));
      expect(workout.date, equals(''));
      expect(workout.name, equals('Workout'));
      expect(workout.duration, equals(0));
      expect(workout.exercises, isEmpty);
    });

    test('Workout persists and restores through storage', () async {
      final workout = Workout(
        id: 'w1',
        date: '2026-02-20T10:00:00.000Z',
        name: 'Full Workout',
        duration: 5400,
        exercises: [
          WorkoutExercise(
            exerciseId: 'squat',
            name: 'Squat',
            muscle: 'Legs',
            sets: [
              WorkoutSet(weight: '100', reps: '5'),
              WorkoutSet(weight: '110', reps: '5'),
            ],
          ),
          WorkoutExercise(
            exerciseId: 'bench-press',
            name: 'Bench Press',
            muscle: 'Chest',
            sets: [
              WorkoutSet(weight: '80', reps: '8'),
            ],
          ),
        ],
      );

      await saveWorkout(workout);
      final restored = (await getWorkouts()).first;

      expect(restored.id, equals('w1'));
      expect(restored.exercises.length, equals(2));
      expect(restored.exercises[0].sets.length, equals(2));
      expect(restored.exercises[1].sets.first.weight, equals('80'));
    });
  });

  group('Custom Exercise Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    test('getCustomExercises returns empty list when none exist', () async {
      final exercises = await getCustomExercises();
      expect(exercises, isEmpty);
    });

    test('addCustomExercise adds and persists an exercise', () async {
      const exercise = Exercise(
        id: 'custom-1',
        name: 'Zercher Squat',
        muscle: 'Legs',
        category: 'Barbell',
        icon: Icons.fitness_center,
        custom: true,
      );

      await addCustomExercise(exercise);
      final exercises = await getCustomExercises();

      expect(exercises.length, equals(1));
      expect(exercises.first.id, equals('custom-1'));
      expect(exercises.first.name, equals('Zercher Squat'));
      expect(exercises.first.muscle, equals('Legs'));
      expect(exercises.first.category, equals('Barbell'));
      expect(exercises.first.custom, isTrue);
    });

    test('addCustomExercise returns updated list', () async {
      const exercise = Exercise(
        id: 'custom-1',
        name: 'Test Exercise',
        muscle: 'Chest',
        category: 'Dumbbell',
        icon: Icons.fitness_center,
        custom: true,
      );

      final result = await addCustomExercise(exercise);
      expect(result.length, equals(1));
    });

    test('multiple custom exercises accumulate', () async {
      const ex1 = Exercise(
        id: 'c1', name: 'Exercise 1', muscle: 'Chest',
        category: 'Barbell', icon: Icons.fitness_center, custom: true,
      );
      const ex2 = Exercise(
        id: 'c2', name: 'Exercise 2', muscle: 'Back',
        category: 'Cable', icon: Icons.call_split, custom: true,
      );

      await addCustomExercise(ex1);
      await addCustomExercise(ex2);
      final exercises = await getCustomExercises();

      expect(exercises.length, equals(2));
    });

    test('deleteCustomExercise removes the exercise', () async {
      const ex1 = Exercise(
        id: 'c1', name: 'Exercise 1', muscle: 'Chest',
        category: 'Barbell', icon: Icons.fitness_center, custom: true,
      );
      const ex2 = Exercise(
        id: 'c2', name: 'Exercise 2', muscle: 'Back',
        category: 'Cable', icon: Icons.call_split, custom: true,
      );

      await addCustomExercise(ex1);
      await addCustomExercise(ex2);
      await deleteCustomExercise('c1');

      final exercises = await getCustomExercises();
      expect(exercises.length, equals(1));
      expect(exercises.first.id, equals('c2'));
    });

    test('deleteCustomExercise with non-existent id is no-op', () async {
      const exercise = Exercise(
        id: 'c1', name: 'Exercise 1', muscle: 'Chest',
        category: 'Barbell', icon: Icons.fitness_center, custom: true,
      );

      await addCustomExercise(exercise);
      await deleteCustomExercise('non-existent');

      final exercises = await getCustomExercises();
      expect(exercises.length, equals(1));
    });
  });

  group('Profile Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    test('getProfile returns defaults when no profile saved', () async {
      final profile = await getProfile();
      expect(profile['name'], equals(''));
      expect(profile['unit'], equals('kg'));
    });

    test('saveProfile and getProfile round-trip', () async {
      await saveProfile({'name': 'John', 'unit': 'lbs'});
      final profile = await getProfile();

      expect(profile['name'], equals('John'));
      expect(profile['unit'], equals('lbs'));
    });

    test('saveProfile overwrites previous profile', () async {
      await saveProfile({'name': 'John', 'unit': 'kg'});
      await saveProfile({'name': 'Jane', 'unit': 'lbs'});

      final profile = await getProfile();
      expect(profile['name'], equals('Jane'));
      expect(profile['unit'], equals('lbs'));
    });
  });

  group('Stats Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    test('getStats returns zeroes with no workouts', () async {
      final stats = await getStats();

      expect(stats.totalWorkouts, equals(0));
      expect(stats.weekWorkouts, equals(0));
      expect(stats.totalSets, equals(0));
      expect(stats.totalVolume, equals(0));
      expect(stats.streak, equals(0));
      expect(stats.muscleDistribution, isEmpty);
      expect(stats.personalRecords, isEmpty);
      expect(stats.recentWorkouts, isEmpty);
    });

    test('getStats calculates total workouts and sets', () async {
      final workout = Workout(
        id: 'w1',
        date: '2026-02-20T10:00:00.000Z',
        name: 'Test',
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
      final stats = await getStats();

      expect(stats.totalWorkouts, equals(1));
      expect(stats.totalSets, equals(2));
      // Volume: (60*10) + (70*8) = 600 + 560 = 1160
      expect(stats.totalVolume, equals(1160));
    });

    test('getStats counts this week workouts', () async {
      final today = DateTime.now();
      final workout = Workout(
        id: 'w1',
        date: today.toIso8601String(),
        name: 'Today Workout',
        duration: 3600,
        exercises: [],
      );

      await saveWorkout(workout);
      final stats = await getStats();

      expect(stats.weekWorkouts, greaterThanOrEqualTo(1));
    });

    test('getStats calculates streak for consecutive days', () async {
      final today = DateTime.now();
      final todayWorkout = Workout(
        id: 'w1',
        date: DateTime(today.year, today.month, today.day, 10).toIso8601String(),
        name: 'Today',
        duration: 3600,
        exercises: [],
      );
      final yesterdayWorkout = Workout(
        id: 'w2',
        date: DateTime(today.year, today.month, today.day - 1, 10).toIso8601String(),
        name: 'Yesterday',
        duration: 3600,
        exercises: [],
      );

      await saveWorkout(todayWorkout);
      await saveWorkout(yesterdayWorkout);
      final stats = await getStats();

      expect(stats.streak, equals(2));
    });

    test('getStats streak is zero when no workout today', () async {
      final workout = Workout(
        id: 'w1',
        date: '2025-01-01T10:00:00.000Z',
        name: 'Old Workout',
        duration: 3600,
        exercises: [],
      );

      await saveWorkout(workout);
      final stats = await getStats();

      expect(stats.streak, equals(0));
    });

    test('getStats builds muscle distribution', () async {
      final workout = Workout(
        id: 'w1',
        date: '2026-02-20T10:00:00.000Z',
        name: 'Full Body',
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
          WorkoutExercise(
            exerciseId: 'squat',
            name: 'Squat',
            muscle: 'Legs',
            sets: [
              WorkoutSet(weight: '100', reps: '5'),
            ],
          ),
        ],
      );

      await saveWorkout(workout);
      final stats = await getStats();

      expect(stats.muscleDistribution['Chest'], equals(2));
      expect(stats.muscleDistribution['Legs'], equals(1));
    });

    test('getStats tracks personal records', () async {
      final workout = Workout(
        id: 'w1',
        date: '2026-02-20T10:00:00.000Z',
        name: 'PR Day',
        duration: 3600,
        exercises: [
          WorkoutExercise(
            exerciseId: 'bench-press',
            name: 'Bench Press',
            muscle: 'Chest',
            sets: [
              WorkoutSet(weight: '60', reps: '10'),
              WorkoutSet(weight: '100', reps: '1'),
              WorkoutSet(weight: '80', reps: '5'),
            ],
          ),
        ],
      );

      await saveWorkout(workout);
      final stats = await getStats();

      expect(stats.personalRecords.containsKey('bench-press'), isTrue);
      expect(stats.personalRecords['bench-press']!.weight, equals(100));
      expect(stats.personalRecords['bench-press']!.reps, equals('1'));
    });

    test('getStats returns at most 5 recent workouts', () async {
      for (int i = 0; i < 7; i++) {
        await saveWorkout(Workout(
          id: 'w$i',
          date: '2026-02-${20 + i}T10:00:00.000Z',
          name: 'Workout $i',
          duration: 3600,
          exercises: [],
        ));
      }

      final stats = await getStats();
      expect(stats.recentWorkouts.length, equals(5));
    });

    test('getStats PR updates across multiple workouts', () async {
      final w1 = Workout(
        id: 'w1',
        date: '2026-02-15T10:00:00.000Z',
        name: 'Week 1',
        duration: 3600,
        exercises: [
          WorkoutExercise(
            exerciseId: 'squat',
            name: 'Squat',
            muscle: 'Legs',
            sets: [WorkoutSet(weight: '100', reps: '5')],
          ),
        ],
      );
      final w2 = Workout(
        id: 'w2',
        date: '2026-02-22T10:00:00.000Z',
        name: 'Week 2',
        duration: 3600,
        exercises: [
          WorkoutExercise(
            exerciseId: 'squat',
            name: 'Squat',
            muscle: 'Legs',
            sets: [WorkoutSet(weight: '120', reps: '3')],
          ),
        ],
      );

      await saveWorkout(w1);
      await saveWorkout(w2);
      final stats = await getStats();

      expect(stats.personalRecords['squat']!.weight, equals(120));
    });
  });

  group('Exercise Progress Edge Cases', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    test('getExerciseProgress handles exercise appearing twice in same workout', () async {
      final workout = Workout(
        id: 'w1',
        date: '2026-02-20T10:00:00.000Z',
        name: 'Double Bench',
        duration: 3600,
        exercises: [
          WorkoutExercise(
            exerciseId: 'bench-press',
            name: 'Bench Press',
            muscle: 'Chest',
            sets: [WorkoutSet(weight: '60', reps: '10')],
          ),
          WorkoutExercise(
            exerciseId: 'bench-press',
            name: 'Bench Press',
            muscle: 'Chest',
            sets: [WorkoutSet(weight: '80', reps: '6')],
          ),
        ],
      );

      await saveWorkout(workout);
      final progress = await getExerciseProgress('bench-press');

      // Both entries should be counted
      expect(progress.totalSets, equals(2));
      expect(progress.maxWeight, equals(80));
      // But it's still one workout
      expect(progress.totalWorkouts, equals(1));
      // Volume: (60*10) + (80*6) = 600 + 480 = 1080
      expect(progress.totalVolume, equals(1080));
    });
  });
}
