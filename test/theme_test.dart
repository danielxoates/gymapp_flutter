import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/theme.dart';

void main() {
  group('AppTheme', () {
    group('Color constants', () {
      test('bg is dark black', () {
        expect(AppTheme.bg, equals(const Color(0xFF0D0D0D)));
      });

      test('bgCard is dark blue', () {
        expect(AppTheme.bgCard, equals(const Color(0xFF1A1A2E)));
      });

      test('primary is purple', () {
        expect(AppTheme.primary, equals(const Color(0xFF6C63FF)));
      });

      test('semantic colors are correct', () {
        expect(AppTheme.success, equals(const Color(0xFF00C853)));
        expect(AppTheme.warning, equals(const Color(0xFFFFB300)));
        expect(AppTheme.danger, equals(const Color(0xFFFF5252)));
        expect(AppTheme.info, equals(const Color(0xFF40C4FF)));
      });

      test('text colors are correct', () {
        expect(AppTheme.text, equals(const Color(0xFFEAEAEA)));
        expect(AppTheme.textSecondary, equals(const Color(0xFF9E9E9E)));
        expect(AppTheme.textMuted, equals(const Color(0xFF5C5C7A)));
        expect(AppTheme.textInverse, equals(const Color(0xFF0D0D0D)));
      });
    });

    group('Typography sizes', () {
      test('font sizes form ascending scale', () {
        expect(AppTheme.fontXs, lessThan(AppTheme.fontSm));
        expect(AppTheme.fontSm, lessThan(AppTheme.fontMd));
        expect(AppTheme.fontMd, lessThan(AppTheme.fontLg));
        expect(AppTheme.fontLg, lessThan(AppTheme.fontXl));
        expect(AppTheme.fontXl, lessThan(AppTheme.fontXxl));
        expect(AppTheme.fontXxl, lessThan(AppTheme.fontHero));
      });

      test('font sizes have expected values', () {
        expect(AppTheme.fontXs, equals(11));
        expect(AppTheme.fontSm, equals(13));
        expect(AppTheme.fontMd, equals(15));
        expect(AppTheme.fontLg, equals(18));
        expect(AppTheme.fontXl, equals(22));
        expect(AppTheme.fontXxl, equals(28));
        expect(AppTheme.fontHero, equals(36));
      });
    });

    group('Spacing', () {
      test('spacing values form ascending scale', () {
        expect(AppTheme.spacingXs, lessThan(AppTheme.spacingSm));
        expect(AppTheme.spacingSm, lessThan(AppTheme.spacingMd));
        expect(AppTheme.spacingMd, lessThan(AppTheme.spacingLg));
        expect(AppTheme.spacingLg, lessThan(AppTheme.spacingXl));
        expect(AppTheme.spacingXl, lessThan(AppTheme.spacingXxl));
      });
    });

    group('Border radius', () {
      test('radius values form ascending scale', () {
        expect(AppTheme.radiusSm, lessThan(AppTheme.radiusMd));
        expect(AppTheme.radiusMd, lessThan(AppTheme.radiusLg));
        expect(AppTheme.radiusLg, lessThan(AppTheme.radiusXl));
        expect(AppTheme.radiusXl, lessThan(AppTheme.radiusFull));
      });

      test('radiusFull is large enough for pill shapes', () {
        expect(AppTheme.radiusFull, equals(999));
      });
    });

    group('Card shadow', () {
      test('returns a valid box shadow list', () {
        final shadows = AppTheme.cardShadow;
        expect(shadows, isNotEmpty);
        expect(shadows.length, equals(1));
        expect(shadows.first.blurRadius, equals(12));
        expect(shadows.first.offset, equals(const Offset(0, 4)));
      });
    });

    group('ThemeData', () {
      test('creates valid ThemeData', () {
        final theme = AppTheme.themeData;
        expect(theme, isA<ThemeData>());
        expect(theme.brightness, equals(Brightness.dark));
        expect(theme.scaffoldBackgroundColor, equals(AppTheme.bg));
      });

      test('sets correct color scheme', () {
        final theme = AppTheme.themeData;
        expect(theme.colorScheme.primary, equals(AppTheme.primary));
        expect(theme.colorScheme.surface, equals(AppTheme.bgCard));
        expect(theme.colorScheme.onPrimary, equals(Colors.white));
        expect(theme.colorScheme.onSurface, equals(AppTheme.text));
      });

      test('sets correct app bar theme', () {
        final theme = AppTheme.themeData;
        expect(theme.appBarTheme.backgroundColor, equals(AppTheme.bgCard));
        expect(theme.appBarTheme.foregroundColor, equals(AppTheme.text));
        expect(theme.appBarTheme.elevation, equals(0));
      });

      test('sets correct bottom nav bar theme', () {
        final theme = AppTheme.themeData;
        final navTheme = theme.bottomNavigationBarTheme;
        expect(navTheme.backgroundColor, equals(AppTheme.bgCard));
        expect(navTheme.selectedItemColor, equals(AppTheme.primary));
        expect(navTheme.unselectedItemColor, equals(AppTheme.textMuted));
      });
    });
  });
}
