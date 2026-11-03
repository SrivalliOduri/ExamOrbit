import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Brand colors shared by the theme and gradient surfaces.
abstract final class AppColors {
  static const purple = Color(0xFF6A4BC4);
  static const teal = Color(0xFF0B7A70);
  static const tealLight = Color(0xFF4FD1C5);

  static const heroGradient = LinearGradient(
    colors: [purple, teal],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

/// Light and dark Material 3 themes using Poppins.
abstract final class AppTheme {
  static final ThemeData light = _build(Brightness.light);
  static final ThemeData dark = _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.purple,
      brightness: brightness,
    ).copyWith(
      secondary: isDark ? AppColors.tealLight : AppColors.teal,
      onSecondary: isDark ? Colors.black : Colors.white,
    );
    final base = ThemeData(useMaterial3: true, colorScheme: scheme);

    return base.copyWith(
      scaffoldBackgroundColor: scheme.surfaceContainerLow,
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surfaceContainerLow,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? scheme.surfaceContainerHigh : scheme.surfaceContainerLowest,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
