import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReaderTheme {
  // Warm, paper-like color scheme
  static const lightBackground = Color(0xFFFBF9F6);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightText = Color(0xFF2D2D2D);
  static const lightTextSecondary = Color(0xFF6B6B6B);
  static const lightAccent = Color(0xFF8B7355);
  static const lightBorder = Color(0xFFE8E4DF);

  // Dark mode with reduced contrast for comfort
  static const darkBackground = Color(0xFF1A1A1A);
  static const darkSurface = Color(0xFF222222);
  static const darkText = Color(0xFFE8E8E8);
  static const darkTextSecondary = Color(0xFFAAAAAA);
  static const darkAccent = Color(0xFFB8956A);
  static const darkBorder = Color(0xFF333333);

  static TextTheme readerTextTheme(bool isDark) {
    final baseStyle = GoogleFonts.literata(
      color: isDark ? darkText : lightText,
      height: 1.7,
      letterSpacing: 0.1,
    );

    return TextTheme(
      displayLarge: baseStyle.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.5,
      ),
      displayMedium: baseStyle.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        height: 1.3,
      ),
      displaySmall: baseStyle.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.4,
      ),
      headlineLarge: baseStyle.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: 1.4,
      ),
      headlineMedium: baseStyle.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.4,
      ),
      headlineSmall: baseStyle.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.5,
      ),
      bodyLarge: baseStyle.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        height: 1.7,
      ),
      bodyMedium: baseStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.7,
      ),
      bodySmall: baseStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.6,
      ),
    );
  }

  static ThemeData lightReaderTheme() {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBackground,
      colorScheme: const ColorScheme.light(
        primary: lightAccent,
        surface: lightSurface,
        onSurface: lightText,
      ),
      textTheme: readerTextTheme(false),
      dividerColor: lightBorder,
      iconTheme: const IconThemeData(color: lightTextSecondary),
    );
  }

  static ThemeData darkReaderTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: darkAccent,
        surface: darkSurface,
        onSurface: darkText,
      ),
      textTheme: readerTextTheme(true),
      dividerColor: darkBorder,
      iconTheme: const IconThemeData(color: darkTextSecondary),
    );
  }
}
