import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/data/storage.dart';
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
  });
}
