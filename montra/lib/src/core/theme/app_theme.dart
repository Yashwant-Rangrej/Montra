import 'package:flutter/material.dart';

class AppTheme {
  // New UI Design Tokens
  static const Color primary = Color(0xFF4252B6); // Indigo Blue
  static const Color onPrimary = Colors.white;
  static const Color primaryContainer = Color(0xFFE8EAF6);
  static const Color onPrimaryContainer = Color(0xFF1A237E);

  static const Color secondary = Color(0xFF4252B6); // Indigo
  static const Color onSecondary = Colors.white;
  static const Color secondaryContainer = Color(0xFFF1F5F9);
  static const Color onSecondaryContainer = Color(0xFF0F172A);

  static const Color background = Color(0xFFFDFBF7); // Warm Cream Background
  static const Color onBackground = Color(0xFF11142D);
  static const Color surface = Colors.white;
  static const Color onSurface = Color(0xFF11142D);

  static const Color error = Color(0xFFEF4444);
  static const Color onError = Colors.white;
  
  static const Color expense = Color(0xFFEB5757); // Red
  static const Color income = Color(0xFF27AE60); // Green
  static const Color transfer = Color(0xFF2F80ED); // Blue

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
        surface: surface,
        onSurface: onSurface,
        error: error,
        onError: onError,
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        foregroundColor: onSurface,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: onSurface),
        displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: onSurface),
        displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: onSurface),
        headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: onSurface),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: onSurface),
        bodyLarge: TextStyle(fontSize: 16, color: onSurface),
        bodyMedium: TextStyle(fontSize: 14, color: onSurface),
      ),
    );
  }
}
