import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'exercises.dart';

const _keyWorkouts = '@gym_workouts';
const _keyCustomExercises = '@gym_custom_exercises';
const _keyProfile = '@gym_profile';

// ─── Generic helpers ─────────────────────────────────────
Future<dynamic> _getJSON(String key) async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString(key);
  if (raw == null) return null;
  return jsonDecode(raw);
}

Future<void> _setJSON(String key, dynamic value) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(key, jsonEncode(value));
}

// ─── Workouts ────────────────────────────────────────────
class WorkoutSet {
  String weight;
  String reps;

  WorkoutSet({this.weight = '', this.reps = ''});

  Map<String, dynamic> toJson() => {'weight': weight, 'reps': reps};

  factory WorkoutSet.fromJson(Map<String, dynamic> json) => WorkoutSet(
        weight: json['weight']?.toString() ?? '',
        reps: json['reps']?.toString() ?? '',
      );
}

class WorkoutExercise {
  String exerciseId;
  String name;
  String muscle;
  List<WorkoutSet> sets;

  WorkoutExercise({
    required this.exerciseId,
    required this.name,
    required this.muscle,
    required this.sets,
  });

  Map<String, dynamic> toJson() => {
        'exerciseId': exerciseId,
        'name': name,
        'muscle': muscle,
        'sets': sets.map((s) => s.toJson()).toList(),
      };

  factory WorkoutExercise.fromJson(Map<String, dynamic> json) =>
      WorkoutExercise(
        exerciseId: json['exerciseId'] ?? '',
        name: json['name'] ?? '',
        muscle: json['muscle'] ?? '',
        sets: (json['sets'] as List?)
                ?.map((s) => WorkoutSet.fromJson(s))
                .toList() ??
            [],
      );
}

class Workout {
  String id;
  String date;
  String name;
  int duration; // seconds
  List<WorkoutExercise> exercises;

  Workout({
    required this.id,
    required this.date,
    required this.name,
    required this.duration,
    required this.exercises,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date,
        'name': name,
        'duration': duration,
        'exercises': exercises.map((e) => e.toJson()).toList(),
      };

  factory Workout.fromJson(Map<String, dynamic> json) => Workout(
        id: json['id']?.toString() ?? '',
        date: json['date'] ?? '',
        name: json['name'] ?? 'Workout',
        duration: json['duration'] ?? 0,
        exercises: (json['exercises'] as List?)
                ?.map((e) => WorkoutExercise.fromJson(e))
                .toList() ??
            [],
      );
}

Future<List<Workout>> getWorkouts() async {
  final data = await _getJSON(_keyWorkouts);
  if (data == null) return [];
  return (data as List).map((w) => Workout.fromJson(w)).toList();
}

Future<List<Workout>> saveWorkout(Workout workout) async {
  final all = await getWorkouts();
  all.insert(0, workout); // newest first
  await _setJSON(_keyWorkouts, all.map((w) => w.toJson()).toList());
  return all;
}

Future<List<Workout>> deleteWorkout(String id) async {
  final all = await getWorkouts();
  all.removeWhere((w) => w.id == id);
  await _setJSON(_keyWorkouts, all.map((w) => w.toJson()).toList());
  return all;
}

// ─── Custom exercises ────────────────────────────────────
Future<List<Exercise>> getCustomExercises() async {
  final data = await _getJSON(_keyCustomExercises);
  if (data == null) return [];
  return (data as List).map((e) => Exercise.fromJson(e)).toList();
}

Future<List<Exercise>> addCustomExercise(Exercise exercise) async {
  final all = await getCustomExercises();
  all.add(exercise);
  await _setJSON(_keyCustomExercises, all.map((e) => e.toJson()).toList());
  return all;
}

Future<List<Exercise>> deleteCustomExercise(String id) async {
  final all = await getCustomExercises();
  all.removeWhere((e) => e.id == id);
  await _setJSON(_keyCustomExercises, all.map((e) => e.toJson()).toList());
  return all;
}

// ─── Profile / settings ─────────────────────────────────
Future<Map<String, dynamic>> getProfile() async {
  final data = await _getJSON(_keyProfile);
  return (data as Map<String, dynamic>?) ?? {'name': '', 'unit': 'kg'};
}

Future<void> saveProfile(Map<String, dynamic> profile) async {
  await _setJSON(_keyProfile, profile);
}

// ─── Stats helpers ───────────────────────────────────────
class PersonalRecord {
  final double weight;
  final String reps;
  final String date;
  final String name;

  PersonalRecord({
    required this.weight,
    required this.reps,
    required this.date,
    required this.name,
  });
}

class Stats {
  final int totalWorkouts;
  final int weekWorkouts;
  final int totalSets;
  final double totalVolume;
  final int streak;
  final Map<String, int> muscleDistribution;
  final Map<String, PersonalRecord> personalRecords;
  final List<Workout> recentWorkouts;

  Stats({
    required this.totalWorkouts,
    required this.weekWorkouts,
    required this.totalSets,
    required this.totalVolume,
    required this.streak,
    required this.muscleDistribution,
    required this.personalRecords,
    required this.recentWorkouts,
  });
}

Future<Stats> getStats() async {
  try {
    final allWorkouts = await getWorkouts();
    final workouts = allWorkouts.length > 500
        ? allWorkouts.sublist(0, 500)
        : allWorkouts;

    final now = DateTime.now();
    final startOfWeek =
        DateTime(now.year, now.month, now.day - now.weekday % 7);

    final thisWeek = workouts
        .where((w) => DateTime.parse(w.date).isAfter(startOfWeek))
        .toList();

    int totalSets = 0;
    double totalVolume = 0;

    for (final w in workouts) {
      for (final e in w.exercises) {
        totalSets += e.sets.length;
        for (final s in e.sets) {
          final weight = double.tryParse(s.weight) ?? 0;
          final reps = int.tryParse(s.reps) ?? 0;
          totalVolume += weight * reps;
        }
      }
    }

    // Streak
    int streak = 0;
    final daySet = workouts
        .map((w) {
          final d = DateTime.parse(w.date);
          return DateTime(d.year, d.month, d.day).toString();
        })
        .toSet();

    var d = DateTime(now.year, now.month, now.day);
    int iterations = 0;
    while (daySet.contains(d.toString()) && iterations < 1000) {
      streak++;
      d = d.subtract(const Duration(days: 1));
      iterations++;
    }

    // Muscle group distribution
    final Map<String, int> muscleMap = {};
    for (final w in workouts) {
      for (final e in w.exercises) {
        if (e.muscle.isNotEmpty) {
          muscleMap[e.muscle] = (muscleMap[e.muscle] ?? 0) + e.sets.length;
        }
      }
    }

    // Personal records
    final Map<String, PersonalRecord> prMap = {};
    for (final w in workouts) {
      for (final e in w.exercises) {
        for (final s in e.sets) {
          final weight = double.tryParse(s.weight) ?? 0;
          if (weight > 0 &&
              (!prMap.containsKey(e.exerciseId) ||
                  weight > prMap[e.exerciseId]!.weight)) {
            prMap[e.exerciseId] = PersonalRecord(
              weight: weight,
              reps: s.reps,
              date: w.date,
              name: e.name,
            );
          }
        }
      }
    }

    return Stats(
      totalWorkouts: workouts.length,
      weekWorkouts: thisWeek.length,
      totalSets: totalSets,
      totalVolume: totalVolume,
      streak: streak,
      muscleDistribution: muscleMap,
      personalRecords: prMap,
      recentWorkouts: workouts.take(5).toList(),
    );
  } catch (e) {
    return Stats(
      totalWorkouts: 0,
      weekWorkouts: 0,
      totalSets: 0,
      totalVolume: 0,
      streak: 0,
      muscleDistribution: {},
      personalRecords: {},
      recentWorkouts: [],
    );
  }
}
