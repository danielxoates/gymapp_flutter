import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/screens/history_screen.dart';
import 'package:gym_tracker/theme.dart';
import 'package:gym_tracker/data/storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget testApp(Widget child) => MaterialApp(
      theme: AppTheme.themeData,
      home: child,
    );

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('HistoryScreen', () {
    testWidgets('shows empty state when no workouts', (tester) async {
      await tester.pumpWidget(testApp(const HistoryScreen()));
      await tester.pumpAndSettle();

      expect(find.text('No workout history'), findsOneWidget);
      expect(
        find.text('Complete your first workout to see it here'),
        findsOneWidget,
      );
    });

    testWidgets('shows empty state icon', (tester) async {
      await tester.pumpWidget(testApp(const HistoryScreen()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.description_outlined), findsOneWidget);
    });

    group('with workout data', () {
      setUp(() {
        final workouts = [
          Workout(
            id: 'w1',
            date: '2026-02-15T10:30:00.000Z',
            name: 'Push Day',
            duration: 3600,
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
              WorkoutExercise(
                exerciseId: 'ohp',
                name: 'Overhead Press',
                muscle: 'Shoulders',
                sets: [
                  WorkoutSet(weight: '40', reps: '10'),
                ],
              ),
            ],
          ),
          Workout(
            id: 'w2',
            date: '2026-02-10T14:00:00.000Z',
            name: 'Leg Day',
            duration: 5400,
            exercises: [
              WorkoutExercise(
                exerciseId: 'squat',
                name: 'Squat',
                muscle: 'Legs',
                sets: [
                  WorkoutSet(weight: '100', reps: '5'),
                  WorkoutSet(weight: '110', reps: '3'),
                  WorkoutSet(weight: '120', reps: '1'),
                ],
              ),
            ],
          ),
        ];
        SharedPreferences.setMockInitialValues({
          '@gym_workouts': jsonEncode(workouts.map((w) => w.toJson()).toList()),
        });
      });

      testWidgets('shows workout names', (tester) async {
        await tester.pumpWidget(testApp(const HistoryScreen()));
        await tester.pumpAndSettle();

        expect(find.text('Push Day'), findsOneWidget);
        expect(find.text('Leg Day'), findsOneWidget);
      });

      testWidgets('shows month grouping header', (tester) async {
        await tester.pumpWidget(testApp(const HistoryScreen()));
        await tester.pumpAndSettle();

        expect(find.text('February 2026'), findsOneWidget);
      });

      testWidgets('shows exercise names', (tester) async {
        await tester.pumpWidget(testApp(const HistoryScreen()));
        await tester.pumpAndSettle();

        expect(find.text('Bench Press'), findsOneWidget);
        expect(find.text('Overhead Press'), findsOneWidget);
        expect(find.text('Squat'), findsOneWidget);
      });

      testWidgets('shows set details', (tester) async {
        await tester.pumpWidget(testApp(const HistoryScreen()));
        await tester.pumpAndSettle();

        // e.g. "80×8, 85×6"
        expect(find.text('80×8, 85×6'), findsOneWidget);
        expect(find.text('100×5, 110×3, 120×1'), findsOneWidget);
      });

      testWidgets('shows duration', (tester) async {
        await tester.pumpWidget(testApp(const HistoryScreen()));
        await tester.pumpAndSettle();

        expect(find.text('60 min'), findsOneWidget); // 3600s
        expect(find.text('90 min'), findsOneWidget); // 5400s
      });

      testWidgets('shows total sets count', (tester) async {
        await tester.pumpWidget(testApp(const HistoryScreen()));
        await tester.pumpAndSettle();

        expect(find.text('3 sets'), findsWidgets); // both workouts have 3 sets
      });

      testWidgets('shows volume in kg', (tester) async {
        await tester.pumpWidget(testApp(const HistoryScreen()));
        await tester.pumpAndSettle();

        // Push Day: 80*8 + 85*6 + 40*10 = 640+510+400 = 1550 → 1.6K kg
        expect(find.text('1.6K kg'), findsOneWidget);
      });

      testWidgets('shows edit and delete icons', (tester) async {
        await tester.pumpWidget(testApp(const HistoryScreen()));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.edit_outlined), findsWidgets);
        expect(find.byIcon(Icons.delete_outline), findsWidgets);
      });

      testWidgets('delete icon shows confirmation dialog', (tester) async {
        await tester.pumpWidget(testApp(const HistoryScreen()));
        await tester.pumpAndSettle();

        // Tap the first delete icon
        await tester.tap(find.byIcon(Icons.delete_outline).first);
        await tester.pumpAndSettle();

        expect(find.text('Delete Workout'), findsOneWidget);
        expect(find.text('Cancel'), findsOneWidget);
        expect(find.text('Delete'), findsOneWidget);
      });

      testWidgets('confirming delete removes the workout', (tester) async {
        await tester.pumpWidget(testApp(const HistoryScreen()));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.delete_outline).first);
        await tester.pumpAndSettle();

        await tester.tap(find.text('Delete'));
        await tester.pumpAndSettle();

        // One workout should remain
        expect(find.text('Push Day'), findsNothing);
        expect(find.text('Leg Day'), findsOneWidget);
      });

      testWidgets('cancel delete keeps the workout', (tester) async {
        await tester.pumpWidget(testApp(const HistoryScreen()));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.delete_outline).first);
        await tester.pumpAndSettle();

        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        // Both workouts should remain
        expect(find.text('Push Day'), findsOneWidget);
        expect(find.text('Leg Day'), findsOneWidget);
      });

      testWidgets('shows formatted date', (tester) async {
        await tester.pumpWidget(testApp(const HistoryScreen()));
        await tester.pumpAndSettle();

        // 2026-02-15 is a Sunday
        expect(find.text('Sun, 15 Feb, 10:30'), findsOneWidget);
        expect(find.text('Tue, 10 Feb, 14:00'), findsOneWidget);
      });
    });

    group('with workout across months', () {
      setUp(() {
        final workouts = [
          Workout(
            id: 'w-jan',
            date: '2026-01-15T10:00:00.000Z',
            name: 'January Workout',
            duration: 1800,
            exercises: [],
          ),
          Workout(
            id: 'w-feb',
            date: '2026-02-15T10:00:00.000Z',
            name: 'February Workout',
            duration: 1800,
            exercises: [],
          ),
        ];
        SharedPreferences.setMockInitialValues({
          '@gym_workouts': jsonEncode(workouts.map((w) => w.toJson()).toList()),
        });
      });

      testWidgets('groups workouts by month', (tester) async {
        await tester.pumpWidget(testApp(const HistoryScreen()));
        await tester.pumpAndSettle();

        expect(find.text('January 2026'), findsOneWidget);
        expect(find.text('February 2026'), findsOneWidget);
      });
    });
  });
}
