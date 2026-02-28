import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/screens/dashboard_screen.dart';
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

  group('DashboardScreen', () {
    testWidgets('shows loading text initially', (tester) async {
      await tester.pumpWidget(testApp(const DashboardScreen()));
      // Before pumpAndSettle, it shows loading
      expect(find.text('Loading…'), findsOneWidget);
    });

    testWidgets('shows greeting after loading', (tester) async {
      await tester.pumpWidget(testApp(const DashboardScreen()));
      await tester.pumpAndSettle();

      // Should show one of the greetings
      final hasGreeting = find.textContaining('Good Morning').evaluate().isNotEmpty ||
          find.textContaining('Good Afternoon').evaluate().isNotEmpty ||
          find.textContaining('Good Evening').evaluate().isNotEmpty;
      expect(hasGreeting, isTrue);
    });

    testWidgets('shows training overview subtitle after loading', (tester) async {
      await tester.pumpWidget(testApp(const DashboardScreen()));
      await tester.pumpAndSettle();

      expect(find.text("Here's your training overview"), findsOneWidget);
    });

    testWidgets('shows empty state messages when no workouts', (tester) async {
      await tester.pumpWidget(testApp(const DashboardScreen()));
      await tester.pumpAndSettle();

      // Scroll down to see sections below the fold
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();

      expect(find.text('No data yet'), findsOneWidget);
    });

    testWidgets('shows stat cards with zeroes when no workouts', (tester) async {
      await tester.pumpWidget(testApp(const DashboardScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Workouts'), findsOneWidget);
      expect(find.text('This Week'), findsOneWidget);
      expect(find.text('Total Sets'), findsOneWidget);
      expect(find.text('Volume'), findsOneWidget);
    });

    testWidgets('shows streak badge', (tester) async {
      await tester.pumpWidget(testApp(const DashboardScreen()));
      await tester.pumpAndSettle();

      expect(find.text('0'), findsWidgets); // streak = 0
    });

    testWidgets('shows Start New Workout button', (tester) async {
      await tester.pumpWidget(testApp(const DashboardScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Start New Workout'), findsOneWidget);
    });

    testWidgets('Start New Workout calls onNavigate with index 2', (tester) async {
      int? navigatedTo;
      await tester.pumpWidget(testApp(
        DashboardScreen(onNavigate: (index) => navigatedTo = index),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Start New Workout'));
      expect(navigatedTo, equals(2));
    });

    testWidgets('shows Muscle Focus section header', (tester) async {
      await tester.pumpWidget(testApp(const DashboardScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Muscle Focus'), findsOneWidget);
    });

    testWidgets('shows Recent Workouts section header', (tester) async {
      await tester.pumpWidget(testApp(const DashboardScreen()));
      await tester.pumpAndSettle();

      // Scroll down to see sections below the fold
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();

      expect(find.text('Recent Workouts'), findsOneWidget);
    });

    group('with workout data', () {
      setUp(() {
        final workouts = [
          Workout(
            id: 'w1',
            date: DateTime.now().toIso8601String(),
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
        ];
        SharedPreferences.setMockInitialValues({
          '@gym_workouts': jsonEncode(workouts.map((w) => w.toJson()).toList()),
        });
      });

      testWidgets('shows workout name in recent workouts', (tester) async {
        await tester.pumpWidget(testApp(const DashboardScreen()));
        await tester.pumpAndSettle();

        expect(find.text('Push Day'), findsOneWidget);
      });

      testWidgets('shows exercise names in workout card', (tester) async {
        await tester.pumpWidget(testApp(const DashboardScreen()));
        await tester.pumpAndSettle();

        expect(find.text('Bench Press · 2 sets'), findsOneWidget);
        expect(find.text('Overhead Press · 1 sets'), findsOneWidget);
      });

      testWidgets('shows personal records section', (tester) async {
        await tester.pumpWidget(testApp(const DashboardScreen()));
        await tester.pumpAndSettle();

        // Scroll down to see the personal records section
        await tester.drag(find.byType(ListView), const Offset(0, -800));
        await tester.pumpAndSettle();

        expect(find.text('Personal Records 🏆'), findsOneWidget);
      });

      testWidgets('shows muscle distribution data', (tester) async {
        await tester.pumpWidget(testApp(const DashboardScreen()));
        await tester.pumpAndSettle();

        expect(find.text('Chest'), findsWidgets);
        expect(find.text('Shoulders'), findsWidgets);
      });

      testWidgets('shows non-zero stat values', (tester) async {
        await tester.pumpWidget(testApp(const DashboardScreen()));
        await tester.pumpAndSettle();

        expect(find.text('1'), findsWidgets); // 1 workout
        expect(find.text('3'), findsWidgets); // 3 total sets
      });
    });

    testWidgets('supports pull to refresh', (tester) async {
      await tester.pumpWidget(testApp(const DashboardScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(RefreshIndicator), findsOneWidget);
    });
  });
}
