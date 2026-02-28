import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/data/exercises.dart';

void main() {
  group('Exercise model', () {
    test('toJson produces correct map', () {
      const exercise = Exercise(
        id: 'test-exercise',
        name: 'Test Exercise',
        muscle: 'Chest',
        category: 'Barbell',
        icon: Icons.fitness_center,
        custom: true,
      );

      final json = exercise.toJson();

      expect(json['id'], equals('test-exercise'));
      expect(json['name'], equals('Test Exercise'));
      expect(json['muscle'], equals('Chest'));
      expect(json['category'], equals('Barbell'));
      expect(json['custom'], isTrue);
    });

    test('toJson does not include icon', () {
      const exercise = Exercise(
        id: 'test',
        name: 'Test',
        muscle: 'Chest',
        category: 'Barbell',
        icon: Icons.fitness_center,
      );

      final json = exercise.toJson();
      expect(json.containsKey('icon'), isFalse);
    });

    test('fromJson creates correct Exercise', () {
      final json = {
        'id': 'bench-press',
        'name': 'Bench Press',
        'muscle': 'Chest',
        'category': 'Barbell',
        'custom': false,
      };

      final exercise = Exercise.fromJson(json);

      expect(exercise.id, equals('bench-press'));
      expect(exercise.name, equals('Bench Press'));
      expect(exercise.muscle, equals('Chest'));
      expect(exercise.category, equals('Barbell'));
      expect(exercise.custom, isFalse);
      expect(exercise.icon, equals(Icons.fitness_center));
    });

    test('fromJson defaults custom to false when missing', () {
      final json = {
        'id': 'test',
        'name': 'Test',
        'muscle': 'Chest',
        'category': 'Barbell',
      };

      final exercise = Exercise.fromJson(json);
      expect(exercise.custom, isFalse);
    });

    test('fromJson round-trips correctly', () {
      const original = Exercise(
        id: 'custom-123',
        name: 'My Exercise',
        muscle: 'Back',
        category: 'Cable',
        icon: Icons.call_split,
        custom: true,
      );

      final restored = Exercise.fromJson(original.toJson());

      expect(restored.id, equals(original.id));
      expect(restored.name, equals(original.name));
      expect(restored.muscle, equals(original.muscle));
      expect(restored.category, equals(original.category));
      expect(restored.custom, equals(original.custom));
    });

    group('icon assignment by category', () {
      test('Barbell exercises get fitness_center icon', () {
        final exercise = Exercise.fromJson({
          'id': 'test',
          'name': 'Test',
          'muscle': 'Chest',
          'category': 'Barbell',
        });
        expect(exercise.icon, equals(Icons.fitness_center));
      });

      test('Dumbbell exercises get fitness_center icon', () {
        final exercise = Exercise.fromJson({
          'id': 'test',
          'name': 'Test',
          'muscle': 'Chest',
          'category': 'Dumbbell',
        });
        expect(exercise.icon, equals(Icons.fitness_center));
      });

      test('Cable exercises get call_split icon', () {
        final exercise = Exercise.fromJson({
          'id': 'test',
          'name': 'Test',
          'muscle': 'Back',
          'category': 'Cable',
        });
        expect(exercise.icon, equals(Icons.call_split));
      });

      test('Machine exercises get build_outlined icon', () {
        final exercise = Exercise.fromJson({
          'id': 'test',
          'name': 'Test',
          'muscle': 'Legs',
          'category': 'Machine',
        });
        expect(exercise.icon, equals(Icons.build_outlined));
      });

      test('Bodyweight exercises get accessibility_new icon', () {
        final exercise = Exercise.fromJson({
          'id': 'test',
          'name': 'Test',
          'muscle': 'Core',
          'category': 'Bodyweight',
        });
        expect(exercise.icon, equals(Icons.accessibility_new));
      });

      test('Cardio exercises get directions_run icon', () {
        final exercise = Exercise.fromJson({
          'id': 'test',
          'name': 'Test',
          'muscle': 'Cardio',
          'category': 'Cardio',
        });
        expect(exercise.icon, equals(Icons.directions_run));
      });

      test('unknown category defaults to fitness_center icon', () {
        final exercise = Exercise.fromJson({
          'id': 'test',
          'name': 'Test',
          'muscle': 'Other',
          'category': 'Unknown',
        });
        expect(exercise.icon, equals(Icons.fitness_center));
      });
    });
  });

  group('Muscle groups list', () {
    test('contains expected muscle groups', () {
      expect(muscleGroups, contains('All'));
      expect(muscleGroups, contains('Chest'));
      expect(muscleGroups, contains('Back'));
      expect(muscleGroups, contains('Shoulders'));
      expect(muscleGroups, contains('Legs'));
      expect(muscleGroups, contains('Arms'));
      expect(muscleGroups, contains('Core'));
      expect(muscleGroups, contains('Cardio'));
    });

    test('All is the first item', () {
      expect(muscleGroups.first, equals('All'));
    });

    test('has 8 entries', () {
      expect(muscleGroups.length, equals(8));
    });
  });

  group('Categories list', () {
    test('contains expected categories', () {
      expect(categories, contains('All'));
      expect(categories, contains('Barbell'));
      expect(categories, contains('Dumbbell'));
      expect(categories, contains('Cable'));
      expect(categories, contains('Machine'));
      expect(categories, contains('Bodyweight'));
      expect(categories, contains('Cardio'));
    });

    test('All is the first item', () {
      expect(categories.first, equals('All'));
    });

    test('has 7 entries', () {
      expect(categories.length, equals(7));
    });
  });

  group('Muscle colors map', () {
    test('has color for every muscle group except All', () {
      for (final muscle in muscleGroups.where((m) => m != 'All')) {
        if (muscle == 'Cardio') continue; // Cardio may be missing
        expect(muscleColors.containsKey(muscle), isTrue,
            reason: 'Missing color for $muscle');
      }
    });

    test('all colors are non-transparent', () {
      for (final entry in muscleColors.entries) {
        expect(entry.value.alpha, equals(0xFF),
            reason: '${entry.key} color should be opaque');
      }
    });
  });

  group('Built-in exercises', () {
    test('list is not empty', () {
      expect(builtinExercises, isNotEmpty);
    });

    test('all exercises have valid IDs', () {
      for (final exercise in builtinExercises) {
        expect(exercise.id, isNotEmpty, reason: '${exercise.name} has empty ID');
        expect(exercise.id.contains(' '), isFalse,
            reason: '${exercise.name} ID contains spaces');
      }
    });

    test('all exercises have non-empty names', () {
      for (final exercise in builtinExercises) {
        expect(exercise.name, isNotEmpty);
      }
    });

    test('all exercise IDs are unique', () {
      final ids = builtinExercises.map((e) => e.id).toSet();
      expect(ids.length, equals(builtinExercises.length),
          reason: 'Duplicate exercise IDs found');
    });

    test('all exercises have valid muscle groups', () {
      final validMuscles =
          muscleGroups.where((m) => m != 'All').toSet();
      for (final exercise in builtinExercises) {
        expect(validMuscles.contains(exercise.muscle), isTrue,
            reason:
                '${exercise.name} has invalid muscle group: ${exercise.muscle}');
      }
    });

    test('all exercises have valid categories', () {
      final validCategories =
          categories.where((c) => c != 'All').toSet();
      for (final exercise in builtinExercises) {
        expect(validCategories.contains(exercise.category), isTrue,
            reason:
                '${exercise.name} has invalid category: ${exercise.category}');
      }
    });

    test('no built-in exercises are marked as custom', () {
      for (final exercise in builtinExercises) {
        expect(exercise.custom, isFalse,
            reason: '${exercise.name} should not be custom');
      }
    });

    test('contains exercises for all major muscle groups', () {
      final muscles =
          builtinExercises.map((e) => e.muscle).toSet();
      expect(muscles, contains('Chest'));
      expect(muscles, contains('Back'));
      expect(muscles, contains('Shoulders'));
      expect(muscles, contains('Legs'));
      expect(muscles, contains('Arms'));
      expect(muscles, contains('Core'));
      expect(muscles, contains('Cardio'));
    });

    test('contains well-known exercises', () {
      final names = builtinExercises.map((e) => e.name).toSet();
      expect(names, contains('Bench Press'));
      expect(names, contains('Squat'));
      expect(names, contains('Deadlift'));
      expect(names, contains('Pull Up'));
      expect(names, contains('Overhead Press'));
    });
  });
}
