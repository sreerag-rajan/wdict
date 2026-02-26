import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_decorations.dart';

class AppTheme {
  static ThemeData getTheme(BuildContext context) {
    final textTheme = AppTypography.getTextTheme(context);

    return ThemeData(
      useMaterial3: true,
      fontFamily: GoogleFonts.comicNeue().fontFamily,
      scaffoldBackgroundColor: AppColors.paperWhite,
      primaryColor: AppColors.sketchGreen,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.sketchGreen,
        surface: AppColors.paperWhite,
        primary: AppColors.sketchGreen,
        secondary: AppColors.sketchBrown,
        tertiary: AppColors.sketchBlue,
        error: AppColors.sketchRed,
      ),
      textTheme: textTheme,

      // Card Theme
      cardTheme: const CardThemeData(
        color: AppColors.paperOffWhite,
        elevation: 0, // No rigid digital shadows
        shape: SketchyBorder(),
        margin: EdgeInsets.all(12),
      ),

      // Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.sketchGreen,
          foregroundColor: AppColors.paperWhite,
          elevation: 0,
          shape: const SketchyBorder(color: AppColors.charcoal, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: textTheme.labelLarge,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.charcoal,
          shape: const SketchyBorder(),
          side: const BorderSide(
            color: Colors.transparent,
          ), // Border is painted by SketchyBorder
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: textTheme.labelLarge,
        ),
      ),

      // Input Decoration (Text Fields)
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: AppColors.paperWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          borderSide: BorderSide(color: AppColors.charcoal, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          borderSide: BorderSide(color: AppColors.graphite, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          borderSide: BorderSide(color: AppColors.sketchGreen, width: 2.5),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.paperWhite,
        foregroundColor: AppColors.charcoal,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: const IconThemeData(color: AppColors.charcoal),
      ),
    );
  }
}
