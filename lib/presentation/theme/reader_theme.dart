import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReaderTheme {
  // Desktop-first, professional palette (VS Code / Linear / Notion inspired)
  
  // Light Mode - Clean, stark, technical
  static const lightBackground = Color(0xFFFFFFFF);
  static const lightSurface = Color(0xFFF5F5F5); // Slightly off-white for contrast
  static const lightText = Color(0xFF1F1F1F); // Almost black, sharp
  static const lightTextSecondary = Color(0xFF6E6E6E); // Muted grey
  static const lightAccent = Color(0xFF2B2D31); // Dark grey/black for primary actions (Notion style)
  static const lightBorder = Color(0xFFE0E0E0); // Subtle 1px border
  static const lightError = Color(0xFFD32F2F);

  // Dark Mode - VS Code style, low eye strain
  static const darkBackground = Color(0xFF181818); // VS Code Editor BG approx
  static const darkSurface = Color(0xFF1F1F1F); // Sidebar/Activity Bar
  static const darkText = Color(0xFFCCCCCC); // Standard VS Code text
  static const darkTextSecondary = Color(0xFF858585);
  static const darkAccent = Color(0xFF4D96FF); // Professional blue accent for dark mode
  
  static const darkBorder = Color(0xFF2B2B2B);

  // Typography - Inter for UI, Literata for Reading
  static TextTheme _uiTextTheme(bool isDark) {
    final baseColor = isDark ? darkText : lightText;
    final secondaryColor = isDark ? darkTextSecondary : lightTextSecondary;
    
    // Inter is crisp and technical
    return GoogleFonts.interTextTheme().copyWith(
      displayLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: baseColor,
        letterSpacing: -0.5,
      ),
      displayMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: baseColor,
        letterSpacing: -0.5,
      ),
      displaySmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: baseColor,
      ),
      headlineMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      titleMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: baseColor,
      ),
      bodyLarge: TextStyle(
        fontSize: 14, // Desktop standard
        fontWeight: FontWeight.w400,
        color: baseColor,
        height: 1.4,
      ),
      bodyMedium: TextStyle(
        fontSize: 13, // Desktop dense
        fontWeight: FontWeight.w400,
        color: secondaryColor,
        height: 1.4,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: secondaryColor,
      ),
      labelLarge: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: baseColor,
        letterSpacing: 0.2, // Tighter
      ),
    );
  }

  // Helper for ReaderContent to get the Literata theme if needed manually
  static TextStyle readingTextStyle(bool isDark) {
    return GoogleFonts.literata(
      color: isDark ? darkText : lightText,
      fontSize: 16, // Comfortable reading size
      height: 1.6,
    );
  }

  static ThemeData lightReaderTheme() {
    return _buildTheme(
      brightness: Brightness.light,
      background: lightBackground,
      surface: lightSurface,
      text: lightText,
      textSecondary: lightTextSecondary,
      accent: lightAccent,
      border: lightBorder,
    );
  }

  static ThemeData darkReaderTheme() {
    return _buildTheme(
      brightness: Brightness.dark,
      background: darkBackground,
      surface: darkSurface,
      text: darkText,
      textSecondary: darkTextSecondary,
      accent: darkAccent,
      border: darkBorder,
    );
  }

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color text,
    required Color textSecondary,
    required Color accent,
    required Color border,
  }) {
    final textTheme = _uiTextTheme(brightness == Brightness.dark);

    return ThemeData(
      brightness: brightness,
      scaffoldBackgroundColor: background,
      visualDensity: VisualDensity.compact, // Desktop density
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: accent,
        onPrimary: brightness == Brightness.dark ? background : Colors.white,
        secondary: accent,
        onSecondary: brightness == Brightness.dark ? background : Colors.white,
        error: brightness == Brightness.dark ? const Color(0xFFCF6679) : lightError,
        onError: Colors.white,
        surface: surface,
        onSurface: text,
      ),
      textTheme: textTheme,
      dividerColor: border,
      dividerTheme: DividerThemeData(
        color: border,
        space: 1,
        thickness: 1,
      ),
      iconTheme: IconThemeData(color: textSecondary, size: 18), // Smaller icons
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false, // Desktop usually left-aligned
        titleTextStyle: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        iconTheme: IconThemeData(color: textSecondary, size: 20),
        toolbarHeight: 48, // Dense app bar
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accent,
        foregroundColor: brightness == Brightness.dark ? background : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)), // 4px radius
        elevation: 2,
      ),
      cardTheme: CardThemeData(
        color: background, // Cards often blend or have slight contrast
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8), // Tighter margins
        shape: RoundedRectangleBorder(
          side: BorderSide(color: border),
          borderRadius: BorderRadius.circular(4), // 4px radius
        ),
      ),
      listTileTheme: ListTileThemeData(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        minLeadingWidth: 24,
        minVerticalPadding: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        selectedColor: accent,
        selectedTileColor: accent.withValues(alpha: 0.1),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), // Compact controls
        border: OutlineInputBorder(
          borderSide: BorderSide(color: border),
          borderRadius: BorderRadius.circular(4),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: border),
          borderRadius: BorderRadius.circular(4),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: accent, width: 1.5),
          borderRadius: BorderRadius.circular(4),
        ),
        labelStyle: TextStyle(color: textSecondary, fontSize: 13),
        hintStyle: TextStyle(color: textSecondary.withValues(alpha: 0.7), fontSize: 13),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          textStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: brightness == Brightness.dark ? background : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          elevation: 0,
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: brightness == Brightness.dark ? background : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          elevation: 0,
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          side: BorderSide(color: border),
          textStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(color: border),
        ),
        labelStyle: textTheme.bodySmall?.copyWith(fontSize: 12),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
        side: BorderSide(color: border),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: background,
        selectedItemColor: accent,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
        unselectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(color: border),
        ),
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
      ),
      menuTheme: MenuThemeData(
        style: MenuStyle(
          shape: WidgetStateProperty.all(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: BorderSide(color: border),
          )),
          backgroundColor: WidgetStateProperty.all(background),
          surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
        )
      )
    );
  }
}
