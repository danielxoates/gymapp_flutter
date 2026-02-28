import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/screens/exercises_screen.dart';
import 'package:gym_tracker/theme.dart';
import 'package:gym_tracker/data/exercises.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget testApp(Widget child) => MaterialApp(
      theme: AppTheme.themeData,
      home: Scaffold(body: child),
    );

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ExercisesScreen', () {
    testWidgets('renders search input', (tester) async {
      await tester.pumpWidget(testApp(const ExercisesScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('renders muscle group filter chips', (tester) async {
      await tester.pumpWidget(testApp(const ExercisesScreen()));
      await tester.pumpAndSettle();

      // Should have All + muscle groups
      expect(find.text('All'), findsWidgets); // In both muscle and category rows
      expect(find.text('Chest'), findsWidgets);
      expect(find.text('Back'), findsWidgets);
    });

    testWidgets('renders category filter chips', (tester) async {
      await tester.pumpWidget(testApp(const ExercisesScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Barbell'), findsOneWidget);
      expect(find.text('Dumbbell'), findsOneWidget);
    });

    testWidgets('shows exercise count', (tester) async {
      await tester.pumpWidget(testApp(const ExercisesScreen()));
      await tester.pumpAndSettle();

      // Should show total count of builtinExercises
      expect(
        find.text('${builtinExercises.length} exercises'),
        findsOneWidget,
      );
    });

    testWidgets('shows exercise names from builtin list', (tester) async {
      await tester.pumpWidget(testApp(const ExercisesScreen()));
      await tester.pumpAndSettle();

      // Check a well-known exercise renders
      expect(find.text('Bench Press'), findsWidgets);
    });

    testWidgets('search filters exercises', (tester) async {
      await tester.pumpWidget(testApp(const ExercisesScreen()));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Bench');
      await tester.pumpAndSettle();

      // Should find bench-related exercises
      expect(find.text('Bench Press'), findsWidgets);
      // The count should be less than total
      expect(
        find.text('${builtinExercises.length} exercises'),
        findsNothing,
      );
    });

    testWidgets('muscle group filter works', (tester) async {
      await tester.pumpWidget(testApp(const ExercisesScreen()));
      await tester.pumpAndSettle();

      // Tap the "Legs" chip in the muscle group filter row
      final legsChips = find.text('Legs');
      await tester.tap(legsChips.first);
      await tester.pumpAndSettle();

      // The count should change (fewer exercises)
      final countWidget = find.textContaining(RegExp(r'^\d+ exercises$'));
      expect(countWidget, findsOneWidget);
      final countText = tester.widget<Text>(countWidget);
      // Parse the number from "N exercises"
      final count = int.parse(countText.data!.split(' ').first);
      expect(count, lessThan(builtinExercises.length));
      expect(count, greaterThan(0));
    });

    testWidgets('shows floating action button for adding', (tester) async {
      await tester.pumpWidget(testApp(const ExercisesScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('FAB opens add exercise modal', (tester) async {
      await tester.pumpWidget(testApp(const ExercisesScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('Add Custom Exercise'), findsOneWidget);
      expect(find.text('Exercise Name'), findsOneWidget);
      expect(find.text('Muscle Group'), findsOneWidget);
      expect(find.text('Category'), findsOneWidget);
      expect(find.text('Add Exercise'), findsOneWidget);
    });

    testWidgets('empty add form shows error', (tester) async {
      await tester.pumpWidget(testApp(const ExercisesScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Scroll to make the "Add Exercise" button visible in the modal
      await tester.drag(
        find.text('Exercise Name'),
        const Offset(0, -300),
      );
      await tester.pumpAndSettle();

      // Now tap "Add Exercise" button
      await tester.tap(find.text('Add Exercise'));
      await tester.pumpAndSettle();

      expect(find.text('Error'), findsOneWidget);
      expect(find.text('Please enter an exercise name'), findsOneWidget);
    });

    group('with custom exercises', () {
      setUp(() {
        final customs = [
          const Exercise(
            id: 'custom-1',
            name: 'Zercher Squat',
            muscle: 'Legs',
            category: 'Barbell',
            icon: Icons.fitness_center,
            custom: true,
          ),
        ];
        SharedPreferences.setMockInitialValues({
          '@gym_custom_exercises':
              jsonEncode(customs.map((e) => e.toJson()).toList()),
        });
      });

      testWidgets('shows custom exercises in list', (tester) async {
        await tester.pumpWidget(testApp(const ExercisesScreen()));
        await tester.pumpAndSettle();

        // Custom exercise is at the end of the list, need to search for it
        await tester.enterText(find.byType(TextField), 'Zercher');
        await tester.pumpAndSettle();

        expect(find.text('Zercher Squat'), findsOneWidget);
      });

      testWidgets('custom exercises show Custom label', (tester) async {
        await tester.pumpWidget(testApp(const ExercisesScreen()));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), 'Zercher');
        await tester.pumpAndSettle();

        expect(find.textContaining('Custom'), findsWidgets);
      });

      testWidgets('custom exercises show delete icon', (tester) async {
        await tester.pumpWidget(testApp(const ExercisesScreen()));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), 'Zercher');
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.delete_outline), findsOneWidget);
      });

      testWidgets('tapping custom exercise shows delete dialog', (tester) async {
        await tester.pumpWidget(testApp(const ExercisesScreen()));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), 'Zercher');
        await tester.pumpAndSettle();

        await tester.tap(find.text('Zercher Squat'));
        await tester.pumpAndSettle();

        expect(find.text('Delete Exercise'), findsOneWidget);
        expect(find.text('Remove "Zercher Squat"?'), findsOneWidget);
      });
    });

    testWidgets('disposes search controller', (tester) async {
      await tester.pumpWidget(testApp(const ExercisesScreen()));
      await tester.pumpAndSettle();

      // Navigate away to trigger dispose
      await tester.pumpWidget(testApp(const SizedBox()));
      await tester.pumpAndSettle();

      // No error means dispose worked
    });
  });
}
