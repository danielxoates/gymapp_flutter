import 'package:flutter/material.dart';

class Exercise {
  final String id;
  final String name;
  final String muscle;
  final String category;
  final IconData icon;
  final bool custom;

  const Exercise({
    required this.id,
    required this.name,
    required this.muscle,
    required this.category,
    required this.icon,
    this.custom = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'muscle': muscle,
        'category': category,
        'custom': custom,
      };

  factory Exercise.fromJson(Map<String, dynamic> json) => Exercise(
        id: json['id'],
        name: json['name'],
        muscle: json['muscle'],
        category: json['category'],
        icon: _iconForCategory(json['category']),
        custom: json['custom'] ?? false,
      );

  static IconData _iconForCategory(String category) {
    switch (category) {
      case 'Barbell':
        return Icons.fitness_center;
      case 'Dumbbell':
        return Icons.fitness_center;
      case 'Cable':
        return Icons.call_split;
      case 'Machine':
        return Icons.build_outlined;
      case 'Bodyweight':
        return Icons.accessibility_new;
      case 'Cardio':
        return Icons.directions_run;
      default:
        return Icons.fitness_center;
    }
  }
}

const List<String> muscleGroups = [
  'All',
  'Chest',
  'Back',
  'Shoulders',
  'Legs',
  'Arms',
  'Core',
  'Cardio'
];

const List<String> categories = [
  'All',
  'Barbell',
  'Dumbbell',
  'Cable',
  'Machine',
  'Bodyweight',
  'Cardio'
];

const Map<String, Color> muscleColors = {
  'Chest': Color(0xFFFF6B6B),
  'Back': Color(0xFF4ECDC4),
  'Shoulders': Color(0xFFFFE66D),
  'Legs': Color(0xFF6C63FF),
  'Arms': Color(0xFFFF8A5C),
  'Core': Color(0xFFA8E6CF),
  'Cardio': Color(0xFFFF5252),
};

final List<Exercise> builtinExercises = [
  // === CHEST ===
  const Exercise(
      id: 'bench-press',
      name: 'Bench Press',
      muscle: 'Chest',
      category: 'Barbell',
      icon: Icons.fitness_center),
  const Exercise(
      id: 'incline-bench',
      name: 'Incline Bench Press',
      muscle: 'Chest',
      category: 'Barbell',
      icon: Icons.fitness_center),
  const Exercise(
      id: 'dumbbell-press',
      name: 'Dumbbell Chest Press',
      muscle: 'Chest',
      category: 'Dumbbell',
      icon: Icons.fitness_center),
  const Exercise(
      id: 'incline-db-press',
      name: 'Incline Dumbbell Press',
      muscle: 'Chest',
      category: 'Dumbbell',
      icon: Icons.fitness_center),
  const Exercise(
      id: 'chest-fly',
      name: 'Cable Chest Fly',
      muscle: 'Chest',
      category: 'Cable',
      icon: Icons.call_split),
  const Exercise(
      id: 'push-up',
      name: 'Push Up',
      muscle: 'Chest',
      category: 'Bodyweight',
      icon: Icons.accessibility_new),
  const Exercise(
      id: 'dips-chest',
      name: 'Dips (Chest)',
      muscle: 'Chest',
      category: 'Bodyweight',
      icon: Icons.accessibility_new),
  const Exercise(
      id: 'pec-deck',
      name: 'Pec Deck',
      muscle: 'Chest',
      category: 'Machine',
      icon: Icons.build_outlined),

  // === BACK ===
  const Exercise(
      id: 'deadlift',
      name: 'Deadlift',
      muscle: 'Back',
      category: 'Barbell',
      icon: Icons.fitness_center),
  const Exercise(
      id: 'barbell-row',
      name: 'Barbell Row',
      muscle: 'Back',
      category: 'Barbell',
      icon: Icons.fitness_center),
  const Exercise(
      id: 'pull-up',
      name: 'Pull Up',
      muscle: 'Back',
      category: 'Bodyweight',
      icon: Icons.accessibility_new),
  const Exercise(
      id: 'lat-pulldown',
      name: 'Lat Pulldown',
      muscle: 'Back',
      category: 'Cable',
      icon: Icons.call_split),
  const Exercise(
      id: 'seated-row',
      name: 'Seated Cable Row',
      muscle: 'Back',
      category: 'Cable',
      icon: Icons.call_split),
  const Exercise(
      id: 'db-row',
      name: 'Dumbbell Row',
      muscle: 'Back',
      category: 'Dumbbell',
      icon: Icons.fitness_center),
  const Exercise(
      id: 't-bar-row',
      name: 'T-Bar Row',
      muscle: 'Back',
      category: 'Barbell',
      icon: Icons.fitness_center),
  const Exercise(
      id: 'face-pull',
      name: 'Face Pull',
      muscle: 'Back',
      category: 'Cable',
      icon: Icons.call_split),

  // === SHOULDERS ===
  const Exercise(
      id: 'ohp',
      name: 'Overhead Press',
      muscle: 'Shoulders',
      category: 'Barbell',
      icon: Icons.fitness_center),
  const Exercise(
      id: 'db-shoulder-press',
      name: 'Dumbbell Shoulder Press',
      muscle: 'Shoulders',
      category: 'Dumbbell',
      icon: Icons.fitness_center),
  const Exercise(
      id: 'lateral-raise',
      name: 'Lateral Raise',
      muscle: 'Shoulders',
      category: 'Dumbbell',
      icon: Icons.fitness_center),
  const Exercise(
      id: 'front-raise',
      name: 'Front Raise',
      muscle: 'Shoulders',
      category: 'Dumbbell',
      icon: Icons.fitness_center),
  const Exercise(
      id: 'rear-delt-fly',
      name: 'Rear Delt Fly',
      muscle: 'Shoulders',
      category: 'Dumbbell',
      icon: Icons.fitness_center),
  const Exercise(
      id: 'arnold-press',
      name: 'Arnold Press',
      muscle: 'Shoulders',
      category: 'Dumbbell',
      icon: Icons.fitness_center),
  const Exercise(
      id: 'upright-row',
      name: 'Upright Row',
      muscle: 'Shoulders',
      category: 'Barbell',
      icon: Icons.fitness_center),
  const Exercise(
      id: 'shrugs',
      name: 'Shrugs',
      muscle: 'Shoulders',
      category: 'Dumbbell',
      icon: Icons.fitness_center),

  // === LEGS ===
  const Exercise(
      id: 'squat',
      name: 'Squat',
      muscle: 'Legs',
      category: 'Barbell',
      icon: Icons.fitness_center),
  const Exercise(
      id: 'front-squat',
      name: 'Front Squat',
      muscle: 'Legs',
      category: 'Barbell',
      icon: Icons.fitness_center),
  const Exercise(
      id: 'leg-press',
      name: 'Leg Press',
      muscle: 'Legs',
      category: 'Machine',
      icon: Icons.build_outlined),
  const Exercise(
      id: 'romanian-deadlift',
      name: 'Romanian Deadlift',
      muscle: 'Legs',
      category: 'Barbell',
      icon: Icons.fitness_center),
  const Exercise(
      id: 'leg-curl',
      name: 'Leg Curl',
      muscle: 'Legs',
      category: 'Machine',
      icon: Icons.build_outlined),
  const Exercise(
      id: 'leg-extension',
      name: 'Leg Extension',
      muscle: 'Legs',
      category: 'Machine',
      icon: Icons.build_outlined),
  const Exercise(
      id: 'lunges',
      name: 'Lunges',
      muscle: 'Legs',
      category: 'Dumbbell',
      icon: Icons.fitness_center),
  const Exercise(
      id: 'calf-raise',
      name: 'Calf Raise',
      muscle: 'Legs',
      category: 'Machine',
      icon: Icons.build_outlined),
  const Exercise(
      id: 'hip-thrust',
      name: 'Hip Thrust',
      muscle: 'Legs',
      category: 'Barbell',
      icon: Icons.fitness_center),
  const Exercise(
      id: 'bulgarian-split',
      name: 'Bulgarian Split Squat',
      muscle: 'Legs',
      category: 'Dumbbell',
      icon: Icons.fitness_center),

  // === ARMS ===
  const Exercise(
      id: 'barbell-curl',
      name: 'Barbell Curl',
      muscle: 'Arms',
      category: 'Barbell',
      icon: Icons.fitness_center),
  const Exercise(
      id: 'db-curl',
      name: 'Dumbbell Curl',
      muscle: 'Arms',
      category: 'Dumbbell',
      icon: Icons.fitness_center),
  const Exercise(
      id: 'hammer-curl',
      name: 'Hammer Curl',
      muscle: 'Arms',
      category: 'Dumbbell',
      icon: Icons.fitness_center),
  const Exercise(
      id: 'preacher-curl',
      name: 'Preacher Curl',
      muscle: 'Arms',
      category: 'Dumbbell',
      icon: Icons.fitness_center),
  const Exercise(
      id: 'tricep-pushdown',
      name: 'Tricep Pushdown',
      muscle: 'Arms',
      category: 'Cable',
      icon: Icons.call_split),
  const Exercise(
      id: 'overhead-extension',
      name: 'Overhead Tricep Extension',
      muscle: 'Arms',
      category: 'Dumbbell',
      icon: Icons.fitness_center),
  const Exercise(
      id: 'skull-crusher',
      name: 'Skull Crusher',
      muscle: 'Arms',
      category: 'Barbell',
      icon: Icons.fitness_center),
  const Exercise(
      id: 'close-grip-bench',
      name: 'Close Grip Bench Press',
      muscle: 'Arms',
      category: 'Barbell',
      icon: Icons.fitness_center),
  const Exercise(
      id: 'cable-curl',
      name: 'Cable Curl',
      muscle: 'Arms',
      category: 'Cable',
      icon: Icons.call_split),
  const Exercise(
      id: 'dips-tricep',
      name: 'Dips (Tricep)',
      muscle: 'Arms',
      category: 'Bodyweight',
      icon: Icons.accessibility_new),

  // === CORE ===
  const Exercise(
      id: 'plank',
      name: 'Plank',
      muscle: 'Core',
      category: 'Bodyweight',
      icon: Icons.accessibility_new),
  const Exercise(
      id: 'crunch',
      name: 'Crunch',
      muscle: 'Core',
      category: 'Bodyweight',
      icon: Icons.accessibility_new),
  const Exercise(
      id: 'hanging-leg-raise',
      name: 'Hanging Leg Raise',
      muscle: 'Core',
      category: 'Bodyweight',
      icon: Icons.accessibility_new),
  const Exercise(
      id: 'cable-crunch',
      name: 'Cable Crunch',
      muscle: 'Core',
      category: 'Cable',
      icon: Icons.call_split),
  const Exercise(
      id: 'russian-twist',
      name: 'Russian Twist',
      muscle: 'Core',
      category: 'Bodyweight',
      icon: Icons.accessibility_new),
  const Exercise(
      id: 'ab-wheel',
      name: 'Ab Wheel Rollout',
      muscle: 'Core',
      category: 'Bodyweight',
      icon: Icons.accessibility_new),

  // === CARDIO ===
  const Exercise(
      id: 'treadmill',
      name: 'Treadmill',
      muscle: 'Cardio',
      category: 'Cardio',
      icon: Icons.directions_run),
  const Exercise(
      id: 'cycling',
      name: 'Stationary Bike',
      muscle: 'Cardio',
      category: 'Cardio',
      icon: Icons.pedal_bike),
  const Exercise(
      id: 'rowing-machine',
      name: 'Rowing Machine',
      muscle: 'Cardio',
      category: 'Cardio',
      icon: Icons.rowing),
  const Exercise(
      id: 'elliptical',
      name: 'Elliptical',
      muscle: 'Cardio',
      category: 'Cardio',
      icon: Icons.directions_run),
  const Exercise(
      id: 'jump-rope',
      name: 'Jump Rope',
      muscle: 'Cardio',
      category: 'Cardio',
      icon: Icons.flash_on_outlined),
];
