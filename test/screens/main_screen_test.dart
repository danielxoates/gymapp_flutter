import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/main.dart';
import 'package:gym_tracker/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('GymTrackerApp', () {
    testWidgets('renders MaterialApp with correct title', (tester) async {
      await tester.pumpWidget(const GymTrackerApp());
      await tester.pumpAndSettle();

      final materialApp =
          tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.title, equals('Gym Tracker'));
      expect(materialApp.debugShowCheckedModeBanner, isFalse);
    });

    testWidgets('uses AppTheme.themeData', (tester) async {
      await tester.pumpWidget(const GymTrackerApp());
      await tester.pumpAndSettle();

      final materialApp =
          tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.theme, equals(AppTheme.themeData));
    });
  });

  group('MainScreen', () {
    testWidgets('shows bottom navigation bar with 4 items', (tester) async {
      await tester.pumpWidget(const GymTrackerApp());
      await tester.pumpAndSettle();

      expect(find.byType(BottomNavigationBar), findsOneWidget);

      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Exercises'), findsOneWidget);
      expect(find.text('Workout'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);
    });

    testWidgets('starts on Dashboard tab (index 0)', (tester) async {
      await tester.pumpWidget(const GymTrackerApp());
      await tester.pumpAndSettle();

      final navBar = tester.widget<BottomNavigationBar>(
          find.byType(BottomNavigationBar));
      expect(navBar.currentIndex, equals(0));
    });

    testWidgets('navigating to Exercises tab updates index', (tester) async {
      await tester.pumpWidget(const GymTrackerApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Exercises'));
      await tester.pumpAndSettle();

      final navBar = tester.widget<BottomNavigationBar>(
          find.byType(BottomNavigationBar));
      expect(navBar.currentIndex, equals(1));
    });

    testWidgets('navigating to Workout tab updates index', (tester) async {
      await tester.pumpWidget(const GymTrackerApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Workout'));
      await tester.pumpAndSettle();

      final navBar = tester.widget<BottomNavigationBar>(
          find.byType(BottomNavigationBar));
      expect(navBar.currentIndex, equals(2));
    });

    testWidgets('navigating to History tab updates index', (tester) async {
      await tester.pumpWidget(const GymTrackerApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('History'));
      await tester.pumpAndSettle();

      final navBar = tester.widget<BottomNavigationBar>(
          find.byType(BottomNavigationBar));
      expect(navBar.currentIndex, equals(3));
    });

    testWidgets('uses IndexedStack for screen persistence', (tester) async {
      await tester.pumpWidget(const GymTrackerApp());
      await tester.pumpAndSettle();

      expect(find.byType(IndexedStack), findsOneWidget);
    });
  });
}
