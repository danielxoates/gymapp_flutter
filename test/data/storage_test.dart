import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/data/storage.dart';
import 'package:gym_tracker/data/exercises.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  // ─── WorkoutSet ─────────────────────────────────────────
  group('WorkoutSet', () {
    test('default constructor creates empty strings', () {
      final set = WorkoutSet();
      expect(set.weight, equals(''));
      expect(set.reps, equals(''));
    });

    test('constructor accepts values', () {
      final set = WorkoutSet(weight: '80', reps: '10');
      expect(set.weight, equals('80'));
      expect(set.reps, equals('10'));
    });

    test('toJson produces correct map', () {
      final set = WorkoutSet(weight: '60', reps: '8');
      final json = set.toJson();
      expect(json['weight'], equals('60'));
      expect(json['reps'], equals('8'));
    });

    test('fromJson creates correct WorkoutSet', () {
      final set = WorkoutSet.fromJson({'weight': '100', 'reps': '5'});
      expect(set.weight, equals('100'));
      expect(set.reps, equals('5'));
    });

    test('fromJson handles null values', () {
      final set = WorkoutSet.fromJson({'weight': null, 'reps': null});
      expect(set.weight, equals(''));
      expect(set.reps, equals(''));
    });

    test('fromJson handles missing keys', () {
      final set = WorkoutSet.fromJson({});
      expect(set.weight, equals(''));
      expect(set.reps, equals(''));
    });

    test('fromJson handles numeric values (not strings)', () {
      final set = WorkoutSet.fromJson({'weight': 60, 'reps': 10});
      expect(set.weight, equals('60'));
      expect(set.reps, equals('10'));
    });

    test('round-trip via JSON preserves data', () {
      final original = WorkoutSet(weight: '72.5', reps: '12');
      final restored = WorkoutSet.fromJson(original.toJson());
      expect(restored.weight, equals(original.weight));
      expect(restored.reps, equals(original.reps));
    });
  });

  // ─── WorkoutExercise ───────────────────────────────────
  group('WorkoutExercise', () {
    test('toJson produces correct map', () {
      final exercise = WorkoutExercise(
        exerciseId: 'bench-press',
        name: 'Bench Press',
        muscle: 'Chest',
        sets: [
          WorkoutSet(weight: '60', reps: '10'),
          WorkoutSet(weight: '70', reps: '8'),
        ],
      );

      final json = exercise.toJson();
      expect(json['exerciseId'], equals('bench-press'));
      expect(json['name'], equals('Bench Press'));
      expect(json['muscle'], equals('Chest'));
      expect((json['sets'] as List).length, equals(2));
    });

    test('fromJson creates correct WorkoutExercise', () {
      final json = {
        'exerciseId': 'squat',
        'name': 'Squat',
        'muscle': 'Legs',
        'sets': [
          {'weight': '100', 'reps': '5'},
          {'weight': '110', 'reps': '3'},
        ],
      };

      final exercise = WorkoutExercise.fromJson(json);
      expect(exercise.exerciseId, equals('squat'));
      expect(exercise.name, equals('Squat'));
      expect(exercise.muscle, equals('Legs'));
      expect(exercise.sets.length, equals(2));
      expect(exercise.sets.first.weight, equals('100'));
    });

    test('fromJson handles missing fields', () {
      final exercise = WorkoutExercise.fromJson({});
      expect(exercise.exerciseId, equals(''));
      expect(exercise.name, equals(''));
      expect(exercise.muscle, equals(''));
      expect(exercise.sets, isEmpty);
    });

    test('fromJson handles null sets list', () {
      final exercise =
          WorkoutExercise.fromJson({'exerciseId': 'test', 'sets': null});
      expect(exercise.sets, isEmpty);
    });

    test('round-trip via JSON preserves data', () {
      final original = WorkoutExercise(
        exerciseId: 'deadlift',
        name: 'Deadlift',
        muscle: 'Back',
        sets: [WorkoutSet(weight: '150', reps: '3')],
      );
      final restored = WorkoutExercise.fromJson(original.toJson());
      expect(restored.exerciseId, equals(original.exerciseId));
      expect(restored.name, equals(original.name));
      expect(restored.muscle, equals(original.muscle));
      expect(restored.sets.length, equals(original.sets.length));
      expect(restored.sets.first.weight, equals('150'));
    });
  });

  // ─── Workout ───────────────────────────────────────────
  group('Workout', () {
    test('toJson produces correct map', () {
      final workout = Workout(
        id: 'w1',
        date: '2026-02-20T10:00:00.000Z',
        name: 'Push Day',
        duration: 3600,
        exercises: [],
      );

      final json = workout.toJson();
      expect(json['id'], equals('w1'));
      expect(json['date'], equals('2026-02-20T10:00:00.000Z'));
      expect(json['name'], equals('Push Day'));
      expect(json['duration'], equals(3600));
      expect(json['exercises'], isEmpty);
    });

    test('fromJson creates correct Workout', () {
      final json = {
        'id': 'w2',
        'date': '2026-02-21T09:00:00.000Z',
        'name': 'Leg Day',
        'duration': 5400,
        'exercises': [
          {
            'exerciseId': 'squat',
            'name': 'Squat',
            'muscle': 'Legs',
            'sets': [
              {'weight': '100', 'reps': '5'}
            ],
          }
        ],
      };

      final workout = Workout.fromJson(json);
      expect(workout.id, equals('w2'));
      expect(workout.name, equals('Leg Day'));
      expect(workout.duration, equals(5400));
      expect(workout.exercises.length, equals(1));
      expect(workout.exercises.first.name, equals('Squat'));
    });

    test('fromJson handles missing fields with defaults', () {
      final workout = Workout.fromJson({});
      expect(workout.id, equals(''));
      expect(workout.date, equals(''));
      expect(workout.name, equals('Workout'));
      expect(workout.duration, equals(0));
      expect(workout.exercises, isEmpty);
    });

    test('fromJson handles numeric id', () {
      final workout = Workout.fromJson({'id': 12345});
      expect(workout.id, equals('12345'));
    });

    test('round-trip via JSON preserves data', () {
      final original = Workout(
        id: 'w-test',
        date: '2026-01-15T08:00:00.000Z',
        name: 'Full Body',
        duration: 4500,
        exercises: [
          WorkoutExercise(
            exerciseId: 'bench-press',
            name: 'Bench Press',
            muscle: 'Chest',
            sets: [
              WorkoutSet(weight: '80', reps: '8'),
              WorkoutSet(weight: '85', reps: '6'),
            ],
          ),
        ],
      );

      final restored = Workout.fromJson(original.toJson());
      expect(restored.id, equals(original.id));
      expect(restored.date, equals(original.date));
      expect(restored.name, equals(original.name));
      expect(restored.duration, equals(original.duration));
      expect(restored.exercises.length, equals(1));
      expect(restored.exercises.first.sets.length, equals(2));
    });
  });

  // ─── Workout CRUD operations ───────────────────────────
  group('Workout storage operations', () {
    test('getWorkouts returns empty list when no data', () async {
      final workouts = await getWorkouts();
      expect(workouts, isEmpty);
    });

    test('saveWorkout persists a workout', () async {
      final workout = Workout(
        id: 'w1',
        date: '2026-02-20T10:00:00.000Z',
        name: 'Test Workout',
        duration: 3600,
        exercises: [],
      );

      await saveWorkout(workout);
      final workouts = await getWorkouts();

      expect(workouts.length, equals(1));
      expect(workouts.first.id, equals('w1'));
      expect(workouts.first.name, equals('Test Workout'));
    });

    test('saveWorkout inserts newest first', () async {
      await saveWorkout(Workout(
        id: 'w1',
        date: '2026-02-18T10:00:00.000Z',
        name: 'First',
        duration: 3600,
        exercises: [],
      ));

      await saveWorkout(Workout(
        id: 'w2',
        date: '2026-02-19T10:00:00.000Z',
        name: 'Second',
        duration: 3600,
        exercises: [],
      ));

      final workouts = await getWorkouts();
      expect(workouts.length, equals(2));
      expect(workouts[0].id, equals('w2')); // newest first
      expect(workouts[1].id, equals('w1'));
    });

    test('saveWorkout returns updated list', () async {
      final result = await saveWorkout(Workout(
        id: 'w1',
        date: '2026-02-20T10:00:00.000Z',
        name: 'Test',
        duration: 3600,
        exercises: [],
      ));

      expect(result.length, equals(1));
      expect(result.first.id, equals('w1'));
    });

    test('deleteWorkout removes specific workout', () async {
      await saveWorkout(Workout(
        id: 'w1',
        date: '2026-02-20T10:00:00.000Z',
        name: 'Workout 1',
        duration: 3600,
        exercises: [],
      ));
      await saveWorkout(Workout(
        id: 'w2',
        date: '2026-02-21T10:00:00.000Z',
        name: 'Workout 2',
        duration: 3600,
        exercises: [],
      ));

      final result = await deleteWorkout('w1');
      expect(result.length, equals(1));
      expect(result.first.id, equals('w2'));

      // Verify persisted
      final workouts = await getWorkouts();
      expect(workouts.length, equals(1));
    });

    test('deleteWorkout with non-existent ID does nothing', () async {
      await saveWorkout(Workout(
        id: 'w1',
        date: '2026-02-20T10:00:00.000Z',
        name: 'Test',
        duration: 3600,
        exercises: [],
      ));

      final result = await deleteWorkout('non-existent');
      expect(result.length, equals(1));
    });

    test('updateWorkout modifies existing workout', () async {
      await saveWorkout(Workout(
        id: 'w1',
        date: '2026-02-20T10:00:00.000Z',
        name: 'Original',
        duration: 3600,
        exercises: [],
      ));

      final updated = Workout(
        id: 'w1',
        date: '2026-02-20T10:00:00.000Z',
        name: 'Updated Name',
        duration: 7200,
        exercises: [
          WorkoutExercise(
            exerciseId: 'bench-press',
            name: 'Bench Press',
            muscle: 'Chest',
            sets: [WorkoutSet(weight: '80', reps: '8')],
          ),
        ],
      );

      await updateWorkout(updated);
      final workouts = await getWorkouts();

      expect(workouts.length, equals(1));
      expect(workouts.first.name, equals('Updated Name'));
      expect(workouts.first.duration, equals(7200));
      expect(workouts.first.exercises.length, equals(1));
    });

    test('updateWorkout with non-existent ID does not add workout', () async {
      await saveWorkout(Workout(
        id: 'w1',
        date: '2026-02-20T10:00:00.000Z',
        name: 'Existing',
        duration: 3600,
        exercises: [],
      ));

      await updateWorkout(Workout(
        id: 'non-existent',
        date: '2026-02-21T10:00:00.000Z',
        name: 'Ghost',
        duration: 0,
        exercises: [],
      ));

      final workouts = await getWorkouts();
      expect(workouts.length, equals(1));
      expect(workouts.first.name, equals('Existing'));
    });

    test('saveWorkout preserves exercise and set data', () async {
      await saveWorkout(Workout(
        id: 'w1',
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
              WorkoutSet(weight: '70', reps: '8'),
              WorkoutSet(weight: '80', reps: '6'),
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
      ));

      final workouts = await getWorkouts();
      expect(workouts.first.exercises.length, equals(2));
      expect(workouts.first.exercises[0].sets.length, equals(3));
      expect(workouts.first.exercises[1].sets.first.weight, equals('100'));
    });
  });

  // ─── Custom exercises ──────────────────────────────────
  group('Custom exercises storage', () {
    test('getCustomExercises returns empty list when no data', () async {
      final exercises = await getCustomExercises();
      expect(exercises, isEmpty);
    });

    test('addCustomExercise persists exercise', () async {
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
      expect(exercises.first.custom, isTrue);
    });

    test('addCustomExercise returns updated list', () async {
      const exercise = Exercise(
        id: 'custom-1',
        name: 'Test',
        muscle: 'Chest',
        category: 'Barbell',
        icon: Icons.fitness_center,
        custom: true,
      );

      final result = await addCustomExercise(exercise);
      expect(result.length, equals(1));
    });

    test('deleteCustomExercise removes specific exercise', () async {
      await addCustomExercise(const Exercise(
        id: 'custom-1',
        name: 'Exercise 1',
        muscle: 'Chest',
        category: 'Barbell',
        icon: Icons.fitness_center,
        custom: true,
      ));
      await addCustomExercise(const Exercise(
        id: 'custom-2',
        name: 'Exercise 2',
        muscle: 'Back',
        category: 'Cable',
        icon: Icons.call_split,
        custom: true,
      ));

      final result = await deleteCustomExercise('custom-1');
      expect(result.length, equals(1));
      expect(result.first.id, equals('custom-2'));
    });

    test('multiple custom exercises persist correctly', () async {
      for (int i = 1; i <= 5; i++) {
        await addCustomExercise(Exercise(
          id: 'custom-$i',
          name: 'Exercise $i',
          muscle: 'Chest',
          category: 'Barbell',
          icon: Icons.fitness_center,
          custom: true,
        ));
      }

      final exercises = await getCustomExercises();
      expect(exercises.length, equals(5));
    });
  });

  // ─── Profile ───────────────────────────────────────────
  group('Profile storage', () {
    test('getProfile returns defaults when no data', () async {
      final profile = await getProfile();
      expect(profile['name'], equals(''));
      expect(profile['unit'], equals('kg'));
    });

    test('saveProfile and getProfile round-trip', () async {
      await saveProfile({'name': 'Dan', 'unit': 'lbs'});
      final profile = await getProfile();
      expect(profile['name'], equals('Dan'));
      expect(profile['unit'], equals('lbs'));
    });

    test('saveProfile overwrites previous data', () async {
      await saveProfile({'name': 'Alice', 'unit': 'kg'});
      await saveProfile({'name': 'Bob', 'unit': 'lbs'});
      final profile = await getProfile();
      expect(profile['name'], equals('Bob'));
      expect(profile['unit'], equals('lbs'));
    });
  });

  // ─── Stats ─────────────────────────────────────────────
  group('Stats calculation', () {
    test('getStats returns zeroes when no workouts', () async {
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

    test('getStats counts total workouts correctly', () async {
      for (int i = 0; i < 3; i++) {
        await saveWorkout(Workout(
          id: 'w$i',
          date: '2026-01-${(i + 1).toString().padLeft(2, '0')}T10:00:00.000Z',
          name: 'Workout $i',
          duration: 3600,
          exercises: [],
        ));
      }

      final stats = await getStats();
      expect(stats.totalWorkouts, equals(3));
    });

    test('getStats calculates total sets correctly', () async {
      await saveWorkout(Workout(
        id: 'w1',
        date: '2026-01-15T10:00:00.000Z',
        name: 'Test',
        duration: 3600,
        exercises: [
          WorkoutExercise(
            exerciseId: 'bench',
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
      ));

      final stats = await getStats();
      expect(stats.totalSets, equals(3));
    });

    test('getStats calculates total volume correctly', () async {
      await saveWorkout(Workout(
        id: 'w1',
        date: '2026-01-15T10:00:00.000Z',
        name: 'Test',
        duration: 3600,
        exercises: [
          WorkoutExercise(
            exerciseId: 'bench',
            name: 'Bench Press',
            muscle: 'Chest',
            sets: [
              WorkoutSet(weight: '60', reps: '10'), // 600
              WorkoutSet(weight: '80', reps: '5'), // 400
            ],
          ),
        ],
      ));

      final stats = await getStats();
      expect(stats.totalVolume, equals(1000));
    });

    test('getStats calculates muscle distribution', () async {
      await saveWorkout(Workout(
        id: 'w1',
        date: '2026-01-15T10:00:00.000Z',
        name: 'Push Day',
        duration: 3600,
        exercises: [
          WorkoutExercise(
            exerciseId: 'bench',
            name: 'Bench Press',
            muscle: 'Chest',
            sets: [
              WorkoutSet(weight: '60', reps: '10'),
              WorkoutSet(weight: '70', reps: '8'),
            ],
          ),
          WorkoutExercise(
            exerciseId: 'ohp',
            name: 'OHP',
            muscle: 'Shoulders',
            sets: [
              WorkoutSet(weight: '40', reps: '10'),
            ],
          ),
        ],
      ));

      final stats = await getStats();
      expect(stats.muscleDistribution['Chest'], equals(2));
      expect(stats.muscleDistribution['Shoulders'], equals(1));
    });

    test('getStats tracks personal records', () async {
      await saveWorkout(Workout(
        id: 'w1',
        date: '2026-01-15T10:00:00.000Z',
        name: 'Day 1',
        duration: 3600,
        exercises: [
          WorkoutExercise(
            exerciseId: 'bench',
            name: 'Bench Press',
            muscle: 'Chest',
            sets: [
              WorkoutSet(weight: '60', reps: '10'),
            ],
          ),
        ],
      ));

      await saveWorkout(Workout(
        id: 'w2',
        date: '2026-01-18T10:00:00.000Z',
        name: 'Day 2',
        duration: 3600,
        exercises: [
          WorkoutExercise(
            exerciseId: 'bench',
            name: 'Bench Press',
            muscle: 'Chest',
            sets: [
              WorkoutSet(weight: '80', reps: '5'),
            ],
          ),
        ],
      ));

      final stats = await getStats();
      expect(stats.personalRecords.containsKey('bench'), isTrue);
      expect(stats.personalRecords['bench']!.weight, equals(80));
      expect(stats.personalRecords['bench']!.reps, equals('5'));
    });

    test('getStats limits recent workouts to 5', () async {
      for (int i = 0; i < 10; i++) {
        await saveWorkout(Workout(
          id: 'w$i',
          date: '2026-01-${(i + 1).toString().padLeft(2, '0')}T10:00:00.000Z',
          name: 'Workout $i',
          duration: 3600,
          exercises: [],
        ));
      }

      final stats = await getStats();
      expect(stats.recentWorkouts.length, equals(5));
    });

    test('getStats handles invalid weight/reps gracefully', () async {
      await saveWorkout(Workout(
        id: 'w1',
        date: '2026-01-15T10:00:00.000Z',
        name: 'Bad Data',
        duration: 3600,
        exercises: [
          WorkoutExercise(
            exerciseId: 'bench',
            name: 'Bench Press',
            muscle: 'Chest',
            sets: [
              WorkoutSet(weight: 'abc', reps: 'xyz'),
              WorkoutSet(weight: '', reps: ''),
              WorkoutSet(weight: '60', reps: '10'),
            ],
          ),
        ],
      ));

      final stats = await getStats();
      expect(stats.totalSets, equals(3));
      // Only the valid set contributes to volume
      expect(stats.totalVolume, equals(600));
    });
  });

  // ─── PersonalRecord ────────────────────────────────────
  group('PersonalRecord', () {
    test('stores correct data', () {
      final pr = PersonalRecord(
        weight: 100,
        reps: '5',
        date: '2026-02-20',
        name: 'Bench Press',
      );
      expect(pr.weight, equals(100));
      expect(pr.reps, equals('5'));
      expect(pr.date, equals('2026-02-20'));
      expect(pr.name, equals('Bench Press'));
    });
  });

  // ─── Stats class ───────────────────────────────────────
  group('Stats class', () {
    test('stores all fields correctly', () {
      final stats = Stats(
        totalWorkouts: 10,
        weekWorkouts: 3,
        totalSets: 50,
        totalVolume: 15000,
        streak: 5,
        muscleDistribution: {'Chest': 20, 'Back': 15},
        personalRecords: {},
        recentWorkouts: [],
      );

      expect(stats.totalWorkouts, equals(10));
      expect(stats.weekWorkouts, equals(3));
      expect(stats.totalSets, equals(50));
      expect(stats.totalVolume, equals(15000));
      expect(stats.streak, equals(5));
      expect(stats.muscleDistribution.length, equals(2));
    });
  });
}
