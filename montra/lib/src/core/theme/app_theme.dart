import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color primary = Color(0xFF24389C);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF3F51B5);
  static const Color onPrimaryContainer = Color(0xFFCACFFF);
  
  static const Color secondary = Color(0xFF386753);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFB8EBD1);
  static const Color onSecondaryContainer = Color(0xFF3D6C57);
  
  static const Color tertiary = Color(0xFF762A15);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFF95402A);
  static const Color onTertiaryContainer = Color(0xFFFFC4B5);

  // Surface Colors
  static const Color surface = Color(0xFFFDFAE7);
  static const Color surfaceDim = Color(0xFFDDDBC8);
  static const Color surfaceBright = Color(0xFFFDFAE7);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF7F4E1);
  static const Color surfaceContainer = Color(0xFFF1EEDB);
  static const Color surfaceContainerHigh = Color(0xFFECE9D6);
  static const Color surfaceContainerHighest = Color(0xFFE6E3D0);
  static const Color surfaceVariant = Color(0xFFE6E3D0);

  // Text / Neutrals
  static const Color onSurface = Color(0xFF1C1C11);
  static const Color onSurfaceVariant = Color(0xFF454652);
  static const Color outline = Color(0xFF757684);
  static const Color outlineVariant = Color(0xFFC5C5D4);
  
  static const Color background = Color(0xFFFDFAE7);
  static const Color onBackground = Color(0xFF1C1C11);
  
  // Semantic Colors
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);
  
  static const Color success = Color(0xFF386753); // Mapped to secondary
  static const Color warning = Color(0xFFD97706);
  static const Color info = Color(0xFF2563EB);

  // Custom Domain Colors
  static const Color income = secondary;
  static const Color expense = tertiary;
  static const Color transfer = info;
  
  static const Color divider = outlineVariant;
  static const Color card = surfaceContainerLowest;
  static const Color textPrimary = onSurface;
  static const Color textSecondary = onSurfaceVariant;

  // Shapes & Spacing
  static const double radiusSm = 4.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusPill = 9999.0;
  
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: primary,
        onPrimary: onPrimary,
        primaryContainer: primaryContainer,
        onPrimaryContainer: onPrimaryContainer,
        secondary: secondary,
        onSecondary: onSecondary,
        secondaryContainer: secondaryContainer,
        onSecondaryContainer: onSecondaryContainer,
        tertiary: tertiary,
        onTertiary: onTertiary,
        tertiaryContainer: tertiaryContainer,
        onTertiaryContainer: onTertiaryContainer,
        surface: surface,
        onSurface: onSurface,
        surfaceContainerHighest: surfaceVariant,
        onSurfaceVariant: onSurfaceVariant,
        outline: outline,
        outlineVariant: outlineVariant,
        error: error,
        onError: onError,
        errorContainer: errorContainer,
        onErrorContainer: onErrorContainer,
        background: background,
        onBackground: onBackground,
      ),
      scaffoldBackgroundColor: background,
      dividerColor: divider,
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: onSurface,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusPill),
          ),
          padding: const EdgeInsets.symmetric(horizontal: spacingLg, vertical: spacingMd),
          elevation: 2,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: onSurface,
          side: const BorderSide(color: outlineVariant),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusPill),
          ),
          padding: const EdgeInsets.symmetric(horizontal: spacingLg, vertical: spacingMd),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusPill),
          ),
          padding: const EdgeInsets.symmetric(horizontal: spacingMd, vertical: spacingSm),
        ),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 1, // subtle rest state
        shadowColor: Colors.black.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXl),
        ),
        margin: const EdgeInsets.all(0),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(horizontal: spacingMd, vertical: spacingMd),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          borderSide: const BorderSide(color: outlineVariant, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          borderSide: const BorderSide(color: error, width: 1),
        ),
        labelStyle: const TextStyle(color: onSurfaceVariant),
        hintStyle: const TextStyle(color: outline),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: spacingMd),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w700, height: 40/32, letterSpacing: -0.64, color: textPrimary),
        displayMedium: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, height: 36/28, letterSpacing: -0.56, color: textPrimary),
        displaySmall: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w600, height: 32/24, color: textPrimary),
        headlineLarge: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w700, height: 40/32, letterSpacing: -0.64, color: textPrimary),
        headlineMedium: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w600, height: 32/24, color: textPrimary),
        headlineSmall: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, height: 28/20, color: textPrimary),
        titleLarge: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, height: 24/18, color: textPrimary),
        titleMedium: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, height: 24/16, color: textPrimary),
        bodyLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400, height: 24/16, color: textPrimary),
        bodyMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, height: 20/14, color: textPrimary),
        labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, height: 20/14, letterSpacing: 0.1, color: textSecondary),
        labelMedium: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, height: 16/12, letterSpacing: 0.5, color: textSecondary),
      ),
    );
  }
}
