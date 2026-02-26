import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  static TextTheme getTextTheme(BuildContext context) {
    // We use Comic Neue as the primary font for the hand-drawn feel.
    final baseTheme = GoogleFonts.comicNeueTextTheme(
      Theme.of(context).textTheme,
    );

    return baseTheme.copyWith(
      displayLarge: baseTheme.displayLarge?.copyWith(
        color: AppColors.charcoal,
        fontWeight: FontWeight.bold,
        letterSpacing: -1.0,
      ),
      displayMedium: baseTheme.displayMedium?.copyWith(
        color: AppColors.charcoal,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: baseTheme.displaySmall?.copyWith(
        color: AppColors.charcoal,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: baseTheme.headlineMedium?.copyWith(
        color: AppColors.charcoal,
        fontWeight: FontWeight.bold,
      ),
      headlineSmall: baseTheme.headlineSmall?.copyWith(
        color: AppColors.charcoal,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: baseTheme.titleLarge?.copyWith(
        color: AppColors.charcoal,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: baseTheme.titleMedium?.copyWith(
        color: AppColors.charcoal,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: baseTheme.titleSmall?.copyWith(
        color: AppColors.graphite,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: baseTheme.bodyLarge?.copyWith(color: AppColors.charcoal),
      bodyMedium: baseTheme.bodyMedium?.copyWith(color: AppColors.charcoal),
      labelLarge: baseTheme.labelLarge?.copyWith(
        color: AppColors.charcoal,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.0,
      ),
    );
  }
}
