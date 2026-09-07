// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Thème global SkillUp : fond sable, accents mousse, titres Fraunces.
abstract final class AppTheme {
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.sand,
      colorScheme: const ColorScheme.light(
        primary: AppColors.moss,
        onPrimary: AppColors.sand,
        secondary: AppColors.gold,
        onSecondary: AppColors.ink,
        surface: AppColors.sand,
        onSurface: AppColors.ink,
        error: AppColors.error,
        onError: AppColors.sand,
      ),
    );

    final manrope = GoogleFonts.manropeTextTheme(base.textTheme).apply(
      bodyColor: AppColors.ink,
      displayColor: AppColors.ink,
    );

    return base.copyWith(
      textTheme: manrope.copyWith(
        displayLarge: GoogleFonts.fraunces(
          color: AppColors.forest,
          fontWeight: FontWeight.w600,
        ),
        displayMedium: GoogleFonts.fraunces(
          color: AppColors.forest,
          fontWeight: FontWeight.w600,
        ),
        headlineLarge: GoogleFonts.fraunces(
          color: AppColors.forest,
          fontWeight: FontWeight.w600,
          fontSize: 28,
        ),
        headlineMedium: GoogleFonts.fraunces(
          color: AppColors.forest,
          fontWeight: FontWeight.w600,
          fontSize: 22,
        ),
        headlineSmall: GoogleFonts.fraunces(
          color: AppColors.forest,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
        titleLarge: GoogleFonts.fraunces(
          color: AppColors.forest,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
        titleMedium: GoogleFonts.fraunces(
          color: AppColors.forest,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        bodyLarge: GoogleFonts.manrope(
          color: AppColors.ink,
          fontSize: 16,
          height: 1.45,
        ),
        bodyMedium: GoogleFonts.manrope(
          color: AppColors.ink,
          fontSize: 14,
          height: 1.45,
        ),
        labelLarge: GoogleFonts.manrope(
          color: AppColors.ink,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.forest,
        foregroundColor: AppColors.sand,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.fraunces(
          color: AppColors.sand,
          fontWeight: FontWeight.w600,
          fontSize: 22,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white.withValues(alpha: 0.72),
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.sandMuted, width: 1),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.moss,
          foregroundColor: AppColors.sand,
          textStyle: GoogleFonts.manrope(fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.moss,
      ),
      dividerColor: AppColors.sandMuted,
    );
  }
}
