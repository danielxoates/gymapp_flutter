import 'package:flutter/material.dart';

class AppTheme {
  // Core palette
  static const Color bg = Color(0xFF0D0D0D);
  static const Color bgCard = Color(0xFF1A1A2E);
  static const Color bgSecondary = Color(0xFF16213E);
  static const Color bgInput = Color(0xFF1F1F38);

  // Accent
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF8B83FF);
  static const Color primaryDark = Color(0xFF4A42D4);

  // Semantic
  static const Color success = Color(0xFF00C853);
  static const Color successLight = Color(0xFF69F0AE);
  static const Color warning = Color(0xFFFFB300);
  static const Color danger = Color(0xFFFF5252);
  static const Color info = Color(0xFF40C4FF);

  // Text
  static const Color text = Color(0xFFEAEAEA);
  static const Color textSecondary = Color(0xFF9E9E9E);
  static const Color textMuted = Color(0xFF5C5C7A);
  static const Color textInverse = Color(0xFF0D0D0D);

  // Borders & surfaces
  static const Color border = Color(0xFF2A2A4A);
  static const Color divider = Color(0xFF1E1E3A);
  static const Color overlay = Color(0x99000000);

  // Typography sizes
  static const double fontXs = 11;
  static const double fontSm = 13;
  static const double fontMd = 15;
  static const double fontLg = 18;
  static const double fontXl = 22;
  static const double fontXxl = 28;
  static const double fontHero = 36;

  // Spacing
  static const double spacingXs = 4;
  static const double spacingSm = 8;
  static const double spacingMd = 16;
  static const double spacingLg = 24;
  static const double spacingXl = 32;
  static const double spacingXxl = 48;

  // Border radius
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 24;
  static const double radiusFull = 999;

  // Card shadow
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: primary.withAlpha(38), // 0.15 opacity
          offset: const Offset(0, 4),
          blurRadius: 12,
        ),
      ];

  static ThemeData get themeData => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bg,
        colorScheme: const ColorScheme.dark(
          primary: primary,
          surface: bgCard,
          onPrimary: Colors.white,
          onSurface: text,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: bgCard,
          foregroundColor: text,
          elevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: bgCard,
          selectedItemColor: primary,
          unselectedItemColor: textMuted,
        ),
      );
}
