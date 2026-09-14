import 'package:flutter/material.dart';

/// Central color palette. Calm, respectful, distraction-free.
/// Deep greens/teals with gold accents.
abstract final class AppColors {
  // Brand
  static const Color primary = Color(0xFF0E5C4A); // deep emerald
  static const Color primaryDark = Color(0xFF083C31);
  static const Color secondary = Color(0xFF1C8C74); // teal
  static const Color gold = Color(0xFFC9A24B); // muted gold accent
  static const Color goldSoft = Color(0xFFE4C878);

  // Light scheme surfaces
  static const Color lightBackground = Color(0xFFF6F4EE);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceAlt = Color(0xFFEDE9DF);
  static const Color lightTextPrimary = Color(0xFF16211E);
  static const Color lightTextSecondary = Color(0xFF5A6560);

  // Dark scheme surfaces
  static const Color darkBackground = Color(0xFF0A1512);
  static const Color darkSurface = Color(0xFF11201B);
  static const Color darkSurfaceAlt = Color(0xFF17352C);
  static const Color darkTextPrimary = Color(0xFFF1F4F0);
  static const Color darkTextSecondary = Color(0xFF9DB0A8);

  // Semantic
  static const Color success = Color(0xFF2E9E6B);
  static const Color warning = Color(0xFFD9A441);
  static const Color danger = Color(0xFFC0554B);
}
