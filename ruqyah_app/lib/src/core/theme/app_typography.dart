import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography scale. Latin UI text uses Inter; Arabic Qur'anic text uses the
/// bundled AmiriQuran font (Uthmani-friendly) applied at the widget level.
abstract final class AppTypography {
  static const String arabicFontFamily = 'AmiriQuran';
  static const String arabicUiFontFamily = 'Amiri';

  static TextTheme textTheme(TextTheme base) {
    return GoogleFonts.interTextTheme(base).copyWith(
      displaySmall: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
      titleLarge: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
      titleMedium: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
      bodyLarge: GoogleFonts.inter(fontSize: 16, height: 1.5),
      bodyMedium: GoogleFonts.inter(fontSize: 14, height: 1.5),
      labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
    );
  }

  /// Arabic verse style. [scale] lets the user adjust reading size.
  static TextStyle arabicVerse({
    required Color color,
    double scale = 1.0,
  }) {
    return TextStyle(
      fontFamily: arabicFontFamily,
      fontSize: 30 * scale,
      height: 2.0,
      color: color,
      wordSpacing: 2,
    );
  }

  static TextStyle transliteration({required Color color}) {
    return GoogleFonts.inter(
      fontSize: 15,
      fontStyle: FontStyle.italic,
      height: 1.5,
      color: color,
    );
  }
}
