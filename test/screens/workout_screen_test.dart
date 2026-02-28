import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/screens/workout_screen.dart';
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

  group('WorkoutScreen', () {
    group('inactive state', () {
      testWidgets('shows start workout button', (tester) async {
        await tester.pumpWidget(testApp(const WorkoutScreen()));
        await tester.pumpAndSettle();

        expect(find.text('Start Workout'), findsOneWidget);
      });

      testWidgets('shows motivational header text', (tester) async {
        await tester.pumpWidget(testApp(const WorkoutScreen()));
        await tester.pumpAndSettle();

        expect(find.text('Ready to Train?'), findsOneWidget);
      });

      testWidgets('shows subtitle text', (tester) async {
        await tester.pumpWidget(testApp(const WorkoutScreen()));
        await tester.pumpAndSettle();

        expect(find.text('Track your sets, reps, and weights in real-time'), findsOneWidget);
      });
    });

    group('active state', () {
      testWidgets('tapping Start Workout activates workout', (tester) async {
        await tester.pumpWidget(testApp(const WorkoutScreen()));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Start Workout'));
        await tester.pumpAndSettle();

        // Should now show workout controls
        expect(find.text('Add Exercise'), findsOneWidget);
        expect(find.text('Finish'), findsOneWidget);
      });

      testWidgets('shows timer in active state', (tester) async {
        await tester.pumpWidget(testApp(const WorkoutScreen()));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Start Workout'));
        await tester.pump();

        // Timer starts at 00:00
        expect(find.text('00:00'), findsOneWidget);
      });

      testWidgets('shows empty exercise message initially', (tester) async {
        await tester.pumpWidget(testApp(const WorkoutScreen()));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Start Workout'));
        await tester.pumpAndSettle();

        expect(find.text('No exercises yet'), findsOneWidget);
      });

      testWidgets('finish with no exercises shows alert', (tester) async {
        await tester.pumpWidget(testApp(const WorkoutScreen()));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Start Workout'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Finish'));
        await tester.pumpAndSettle();

        expect(find.text('Empty Workout'), findsOneWidget);
        expect(find.text('Add at least one exercise before saving.'),
            findsOneWidget);
      });

      testWidgets('Add Exercise button opens picker', (tester) async {
        await tester.pumpWidget(testApp(const WorkoutScreen()));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Start Workout'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Add Exercise'));
        await tester.pumpAndSettle();

        // Exercise picker modal header shows "Add Exercise" (the modal title)
        // and muscle group chips are visible
        expect(find.text('All'), findsWidgets);
        expect(find.text('Bench Press'), findsWidgets);
      });

      testWidgets('can add exercise from picker', (tester) async {
        await tester.pumpWidget(testApp(const WorkoutScreen()));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Start Workout'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Add Exercise'));
        await tester.pumpAndSettle();

        // Tap a specific exercise in the picker
        await tester.tap(find.text('Bench Press').first);
        await tester.pumpAndSettle();

        // Exercise should now be added to the workout with a default set
        expect(find.text('Bench Press'), findsOneWidget);
        expect(find.text('No exercises added yet'), findsNothing);
      });

      testWidgets('cancel workout shows confirmation', (tester) async {
        await tester.pumpWidget(testApp(const WorkoutScreen()));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Start Workout'));
        await tester.pumpAndSettle();

        // Find and tap the cancel/discard button (X icon)
        await tester.tap(find.byIcon(Icons.close).first);
        await tester.pumpAndSettle();

        expect(find.text('Discard Workout?'), findsOneWidget);
        expect(find.text('All progress will be lost.'), findsOneWidget);
      });

      testWidgets('discarding workout returns to inactive state', (tester) async {
        await tester.pumpWidget(testApp(const WorkoutScreen()));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Start Workout'));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.close).first);
        await tester.pumpAndSettle();

        await tester.tap(find.text('Discard'));
        await tester.pumpAndSettle();

        expect(find.text('Start Workout'), findsOneWidget);
      });

      testWidgets('keep going dismisses discard dialog', (tester) async {
        await tester.pumpWidget(testApp(const WorkoutScreen()));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Start Workout'));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.close).first);
        await tester.pumpAndSettle();

        await tester.tap(find.text('Keep Going'));
        await tester.pumpAndSettle();

        // Still in active state
        expect(find.text('Finish'), findsOneWidget);
      });
    });

    group('editing existing workout', () {
      testWidgets('starts in active state with pre-populated data', (tester) async {
        final workout = Workout(
          id: 'edit-1',
          date: '2026-02-20T10:00:00.000Z',
          name: 'Push Day',
          duration: 1800,
          exercises: [
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

        await tester.pumpWidget(testApp(
          WorkoutScreen(existingWorkout: workout),
        ));
        await tester.pumpAndSettle();

        // Should be in active state immediately
        expect(find.text('Finish'), findsOneWidget);
        expect(find.text('Push Day'), findsWidgets);
        expect(find.text('Bench Press'), findsOneWidget);
      });

      testWidgets('workout name field is pre-filled', (tester) async {
        final workout = Workout(
          id: 'edit-1',
          date: '2026-02-20T10:00:00.000Z',
          name: 'Leg Day',
          duration: 1800,
          exercises: [],
        );

        await tester.pumpWidget(testApp(
          WorkoutScreen(existingWorkout: workout),
        ));
        await tester.pumpAndSettle();

        // The name controller should have the workout name
        expect(find.text('Leg Day'), findsWidgets);
      });
    });
  });
}
