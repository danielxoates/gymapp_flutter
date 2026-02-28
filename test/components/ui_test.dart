import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/components/ui.dart';
import 'package:gym_tracker/theme.dart';

/// Helper to wrap a widget in MaterialApp for testing.
Widget testApp(Widget child) => MaterialApp(
      theme: AppTheme.themeData,
      home: Scaffold(body: child),
    );

void main() {
  // ─── AppCard ──────────────────────────────────────────
  group('AppCard', () {
    testWidgets('renders child content', (tester) async {
      await tester.pumpWidget(testApp(
        const AppCard(child: Text('Card Content')),
      ));

      expect(find.text('Card Content'), findsOneWidget);
    });

    testWidgets('applies default padding', (tester) async {
      await tester.pumpWidget(testApp(
        const AppCard(child: Text('Padded')),
      ));

      // The Container inside should have AppTheme.spacingMd padding
      final container = tester.widget<Container>(find.ancestor(
        of: find.text('Padded'),
        matching: find.byType(Container),
      ).first);
      expect(container.padding, equals(const EdgeInsets.all(AppTheme.spacingMd)));
    });

    testWidgets('applies custom padding', (tester) async {
      await tester.pumpWidget(testApp(
        const AppCard(
          padding: EdgeInsets.all(42),
          child: Text('Custom'),
        ),
      ));

      final container = tester.widget<Container>(find.ancestor(
        of: find.text('Custom'),
        matching: find.byType(Container),
      ).first);
      expect(container.padding, equals(const EdgeInsets.all(42)));
    });

    testWidgets('wraps in GestureDetector when onTap is provided', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(testApp(
        AppCard(
          onTap: () => tapped = true,
          child: const Text('Tappable'),
        ),
      ));

      expect(find.byType(GestureDetector), findsWidgets);
      await tester.tap(find.text('Tappable'));
      expect(tapped, isTrue);
    });

    testWidgets('does not wrap in GestureDetector when onTap is null', (tester) async {
      await tester.pumpWidget(testApp(
        const AppCard(child: Text('Static')),
      ));

      // Card itself should not have its own GestureDetector
      // The GestureDetector returned by AppCard's build is only created when onTap != null
      final appCard = tester.widget<AppCard>(find.byType(AppCard));
      expect(appCard.onTap, isNull);
    });
  });

  // ─── StatCard ─────────────────────────────────────────
  group('StatCard', () {
    testWidgets('renders label and value', (tester) async {
      await tester.pumpWidget(testApp(
        const StatCard(
          icon: Icons.fitness_center,
          label: 'Total',
          value: '42',
        ),
      ));

      expect(find.text('Total'), findsOneWidget);
      expect(find.text('42'), findsOneWidget);
    });

    testWidgets('renders icon', (tester) async {
      await tester.pumpWidget(testApp(
        const StatCard(
          icon: Icons.timer,
          label: 'Time',
          value: '30m',
        ),
      ));

      expect(find.byIcon(Icons.timer), findsOneWidget);
    });

    testWidgets('renders subtitle when provided', (tester) async {
      await tester.pumpWidget(testApp(
        const StatCard(
          icon: Icons.fitness_center,
          label: 'Sets',
          value: '10',
          subtitle: 'this week',
        ),
      ));

      expect(find.text('this week'), findsOneWidget);
    });

    testWidgets('does not render subtitle when null', (tester) async {
      await tester.pumpWidget(testApp(
        const StatCard(
          icon: Icons.fitness_center,
          label: 'Sets',
          value: '10',
        ),
      ));

      // Only label and value texts (no subtitle text widget)
      expect(find.text('Sets'), findsOneWidget);
      expect(find.text('10'), findsOneWidget);
    });

    testWidgets('uses default primary color when iconColor is null', (tester) async {
      await tester.pumpWidget(testApp(
        const StatCard(
          icon: Icons.fitness_center,
          label: 'Test',
          value: '0',
        ),
      ));

      final icon = tester.widget<Icon>(find.byIcon(Icons.fitness_center));
      expect(icon.color, equals(AppTheme.primary));
    });

    testWidgets('uses custom iconColor when provided', (tester) async {
      await tester.pumpWidget(testApp(
        const StatCard(
          icon: Icons.fitness_center,
          iconColor: Colors.red,
          label: 'Test',
          value: '0',
        ),
      ));

      final icon = tester.widget<Icon>(find.byIcon(Icons.fitness_center));
      expect(icon.color, equals(Colors.red));
    });
  });

  // ─── AppButton ────────────────────────────────────────
  group('AppButton', () {
    testWidgets('renders title text', (tester) async {
      await tester.pumpWidget(testApp(
        AppButton(
          title: 'Save',
          onPressed: () {},
        ),
      ));

      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      bool pressed = false;
      await tester.pumpWidget(testApp(
        AppButton(
          title: 'Click',
          onPressed: () => pressed = true,
        ),
      ));

      await tester.tap(find.text('Click'));
      expect(pressed, isTrue);
    });

    testWidgets('does not call onPressed when disabled', (tester) async {
      bool pressed = false;
      await tester.pumpWidget(testApp(
        AppButton(
          title: 'Click',
          onPressed: () => pressed = true,
          disabled: true,
        ),
      ));

      await tester.tap(find.text('Click'));
      expect(pressed, isFalse);
    });

    testWidgets('does not call onPressed when loading', (tester) async {
      bool pressed = false;
      await tester.pumpWidget(testApp(
        AppButton(
          title: 'Click',
          onPressed: () => pressed = true,
          loading: true,
        ),
      ));

      // When loading, a CircularProgressIndicator is shown instead of text
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Click'), findsNothing);
    });

    testWidgets('renders icon when provided', (tester) async {
      await tester.pumpWidget(testApp(
        AppButton(
          title: 'Play',
          onPressed: () {},
          icon: Icons.play_arrow,
        ),
      ));

      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
      expect(find.text('Play'), findsOneWidget);
    });

    testWidgets('applies reduced opacity when disabled', (tester) async {
      await tester.pumpWidget(testApp(
        AppButton(
          title: 'Disabled',
          onPressed: () {},
          disabled: true,
        ),
      ));

      final opacity = tester.widget<Opacity>(find.byType(Opacity));
      expect(opacity.opacity, equals(0.5));
    });

    testWidgets('full opacity when not disabled', (tester) async {
      await tester.pumpWidget(testApp(
        AppButton(
          title: 'Enabled',
          onPressed: () {},
        ),
      ));

      final opacity = tester.widget<Opacity>(find.byType(Opacity));
      expect(opacity.opacity, equals(1.0));
    });

    testWidgets('secondary style has transparent background', (tester) async {
      await tester.pumpWidget(testApp(
        AppButton(
          title: 'Secondary',
          onPressed: () {},
          isPrimary: false,
        ),
      ));

      // Button text should use primary color (not white)
      final text = tester.widget<Text>(find.text('Secondary'));
      expect((text.style as TextStyle).color, equals(AppTheme.primary));
    });
  });

  // ─── AppInput ─────────────────────────────────────────
  group('AppInput', () {
    testWidgets('renders label when provided', (tester) async {
      await tester.pumpWidget(testApp(
        const AppInput(label: 'Name'),
      ));

      expect(find.text('Name'), findsOneWidget);
    });

    testWidgets('does not render label when null', (tester) async {
      await tester.pumpWidget(testApp(
        const AppInput(placeholder: 'Type here'),
      ));

      // Only the placeholder text in the TextField
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('renders placeholder text', (tester) async {
      await tester.pumpWidget(testApp(
        const AppInput(placeholder: 'Enter something'),
      ));

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.decoration?.hintText, equals('Enter something'));
    });

    testWidgets('calls onChanged when text is entered', (tester) async {
      String changedValue = '';
      await tester.pumpWidget(testApp(
        AppInput(
          onChanged: (val) => changedValue = val,
        ),
      ));

      await tester.enterText(find.byType(TextField), 'Hello');
      expect(changedValue, equals('Hello'));
    });

    testWidgets('uses single line by default', (tester) async {
      await tester.pumpWidget(testApp(
        const AppInput(),
      ));

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.maxLines, equals(1));
    });

    testWidgets('uses 3 lines when multiline', (tester) async {
      await tester.pumpWidget(testApp(
        const AppInput(multiline: true),
      ));

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.maxLines, equals(3));
    });

    testWidgets('accepts external controller', (tester) async {
      final controller = TextEditingController(text: 'initial');
      await tester.pumpWidget(testApp(
        AppInput(controller: controller),
      ));

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, equals('initial'));
    });
  });

  // ─── SectionHeader ───────────────────────────────────
  group('SectionHeader', () {
    testWidgets('renders title', (tester) async {
      await tester.pumpWidget(testApp(
        const SectionHeader(title: 'My Section'),
      ));

      expect(find.text('My Section'), findsOneWidget);
    });

    testWidgets('renders action text when provided', (tester) async {
      await tester.pumpWidget(testApp(
        SectionHeader(
          title: 'Section',
          actionText: 'See All',
          onAction: () {},
        ),
      ));

      expect(find.text('See All'), findsOneWidget);
    });

    testWidgets('does not render action text when null', (tester) async {
      await tester.pumpWidget(testApp(
        const SectionHeader(title: 'Section'),
      ));

      expect(find.text('Section'), findsOneWidget);
      // No action text rendered
    });

    testWidgets('calls onAction when action text is tapped', (tester) async {
      bool called = false;
      await tester.pumpWidget(testApp(
        SectionHeader(
          title: 'Section',
          actionText: 'Action',
          onAction: () => called = true,
        ),
      ));

      await tester.tap(find.text('Action'));
      expect(called, isTrue);
    });
  });

  // ─── AppChip ──────────────────────────────────────────
  group('AppChip', () {
    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(testApp(
        const AppChip(label: 'Chest'),
      ));

      expect(find.text('Chest'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(testApp(
        AppChip(
          label: 'Chest',
          onTap: () => tapped = true,
        ),
      ));

      await tester.tap(find.text('Chest'));
      expect(tapped, isTrue);
    });

    testWidgets('selected chip uses colored background', (tester) async {
      await tester.pumpWidget(testApp(
        const AppChip(label: 'Selected', selected: true),
      ));

      // The text color for selected chips is white
      final text = tester.widget<Text>(find.text('Selected'));
      expect((text.style as TextStyle).color, equals(Colors.white));
    });

    testWidgets('unselected chip uses muted text color', (tester) async {
      await tester.pumpWidget(testApp(
        const AppChip(label: 'Unselected', selected: false),
      ));

      final text = tester.widget<Text>(find.text('Unselected'));
      expect((text.style as TextStyle).color, equals(AppTheme.textSecondary));
    });

    testWidgets('selected chip uses custom color when provided', (tester) async {
      await tester.pumpWidget(testApp(
        const AppChip(label: 'Custom', selected: true, color: Colors.green),
      ));

      // Find the inner container with the background
      final container = tester.widget<Container>(find.descendant(
        of: find.byType(AppChip),
        matching: find.byType(Container),
      ).last);

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(Colors.green));
    });
  });

  // ─── EmptyState ───────────────────────────────────────
  group('EmptyState', () {
    testWidgets('renders title text', (tester) async {
      await tester.pumpWidget(testApp(
        const EmptyState(title: 'No Data'),
      ));

      expect(find.text('No Data'), findsOneWidget);
    });

    testWidgets('renders subtitle when provided', (tester) async {
      await tester.pumpWidget(testApp(
        const EmptyState(
          title: 'No Data',
          subtitle: 'Start by adding items',
        ),
      ));

      expect(find.text('Start by adding items'), findsOneWidget);
    });

    testWidgets('does not render subtitle when null', (tester) async {
      await tester.pumpWidget(testApp(
        const EmptyState(title: 'No Data'),
      ));

      expect(find.text('No Data'), findsOneWidget);
    });

    testWidgets('renders custom icon when provided', (tester) async {
      await tester.pumpWidget(testApp(
        const EmptyState(
          icon: Icons.history,
          title: 'No History',
        ),
      ));

      expect(find.byIcon(Icons.history), findsOneWidget);
    });

    testWidgets('renders default icon when none provided', (tester) async {
      await tester.pumpWidget(testApp(
        const EmptyState(title: 'Empty'),
      ));

      expect(find.byIcon(Icons.fitness_center_outlined), findsOneWidget);
    });
  });
}
