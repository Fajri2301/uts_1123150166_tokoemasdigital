import 'package:flutter/material.dart';

class AppColors {
  // Pro Max Palette - Gold Century
  static const Color primaryLightGold = Color(0xFFFEDEA0);
  static const Color secondaryGold = Color(0xFFCCAB6C);
  static const Color primaryGold = Color(0xFFB38922);
  static const Color darkGray = Color(0xFF34312F);
  
  // Backgrounds & Surfaces
  static const Color bg = Color(0xFF1A1A1A);
  static const Color surface = Color(0xFF262626);
  
  // Texts
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA0A0A0);

  // Semantics
  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Backward Compatibility (Mapped to new dark theme equivalents)
  static const Color primary = primaryGold;
  static const Color primaryLight = primaryLightGold;
  static const Color primaryDark = Color(0xFF8C6B1A);
  static const Color primarySurface = darkGray;
  static const Color primaryBorder = secondaryGold;

  static const Color green = success;
  static const Color greenSurface = Color(0xFF1B3320);
  static const Color amber = warning;
  static const Color amberSurface = Color(0xFF362B16);
  static const Color red = error;
  static const Color redSurface = Color(0xFF361C1C);
  static const Color violet = Color(0xFF7A5AF8);
  static const Color violetSurface = Color(0xFF2B224A);
  static const Color blue = info;
  static const Color blueSurface = Color(0xFF1E293B);
  static const Color gold = primaryGold;
  static const Color goldSurface = darkGray;

  static const Color ink = textPrimary;
  static const Color slate600 = Color(0xFF4B5E78);
  static const Color slate500 = textSecondary;
  static const Color slate400 = Color(0xFF9DABBE);
  static const Color slate300 = Color(0xFFCBD2DD);
  static const Color line = darkGray;
  static const Color line2 = Color(0xFF404040);
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = bg;
  static const Color cardWhite = surface;
  static const Color goldAccent = primaryGold;
  static const Color divider = line;

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.55, 1.0],
    colors: [primaryLightGold, primaryGold, primaryDark],
  );

  // Shadows
  static List<BoxShadow> shadowCard = [
    BoxShadow(
      color: Color(0x33000000),
      blurRadius: 24,
      spreadRadius: 0,
      offset: Offset(0, 4),
    ),
  ];
  static List<BoxShadow> shadowSoft = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 12,
      spreadRadius: 0,
      offset: Offset(0, 2),
    ),
  ];
  static List<BoxShadow> shadowPrimary = [
    BoxShadow(
      color: Color(0x33B38922),
      blurRadius: 22,
      spreadRadius: 0,
      offset: Offset(0, 10),
    ),
  ];

  static Map<String, List<Color>> tones = {
    'gold': [darkGray, primaryGold],
    'blue': [blueSurface, info],
    'green': [greenSurface, success],
    'amber': [amberSurface, warning],
    'red': [redSurface, error],
    'violet': [violetSurface, violet],
    'slate': [bg, slate600],
  };

  static List<Color> tone(String name) => tones[name] ?? tones['gold']!;
}
