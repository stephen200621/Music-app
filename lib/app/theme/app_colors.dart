import 'package:flutter/material.dart';

/// VYBE 3D Color Palette
/// Matches the specification:
/// - Main background: #080914
/// - Secondary background: #111426
/// - Elevated surface: #191D33
/// - Primary accent: #9B5CFF
/// - Secondary accent: #00D9FF
/// - Highlight accent: #FF5CC8
/// - Main text: #F7F7FF
/// - Secondary text: #A7AAC2
/// - Success: #54E6A5
class AppColors {
  AppColors._();

  // Backgrounds
  static const Color mainBackground = Color(0xFF080914);
  static const Color secondaryBackground = Color(0xFF111426);
  static const Color elevatedSurface = Color(0xFF191D33);
  static const Color surfaceCard = Color(0xFF1E233D);
  static const Color surfaceCardHover = Color(0xFF282E4E);

  // Accents
  static const Color primaryAccent = Color(0xFF9B5CFF);
  static const Color secondaryAccent = Color(0xFF00D9FF);
  static const Color highlightAccent = Color(0xFFFF5CC8);
  static const Color success = Color(0xFF54E6A5);
  static const Color warning = Color(0xFFFFB300);
  static const Color error = Color(0xFFFF4B6E);

  // Text
  static const Color mainText = Color(0xFFF7F7FF);
  static const Color secondaryText = Color(0xFFA7AAC2);
  static const Color subtleText = Color(0xFF6B6E8A);

  // Borders & Dividers
  static const Color glassBorder = Color(0x28FFFFFF);
  static const Color divider = Color(0x1FFFFFFF);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryAccent, highlightAccent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cyanPurpleGradient = LinearGradient(
    colors: [secondaryAccent, primaryAccent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient orbGradient = LinearGradient(
    colors: [
      Color(0xFF00D9FF),
      Color(0xFF9B5CFF),
      Color(0xFFFF5CC8),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    colors: [Color(0xFF191D33), Color(0xFF111426)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Glow Shadows
  static List<BoxShadow> get primaryGlow => [
        BoxShadow(
          color: primaryAccent.withOpacity(0.35),
          blurRadius: 24,
          spreadRadius: 2,
        ),
      ];

  static List<BoxShadow> get cyanGlow => [
        BoxShadow(
          color: secondaryAccent.withOpacity(0.35),
          blurRadius: 20,
          spreadRadius: 1,
        ),
      ];

  static List<BoxShadow> get card3dShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.55),
          blurRadius: 28,
          offset: const Offset(0, 16),
          spreadRadius: -4,
        ),
        BoxShadow(
          color: primaryAccent.withOpacity(0.18),
          blurRadius: 36,
          offset: const Offset(0, 10),
          spreadRadius: -8,
        ),
      ];
}
