import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_fonts.dart';
import 'app_constants.dart';

/// Centralized theme configuration
/// All theme changes should be made here
class AppTheme {
  AppTheme._(); // Private constructor to prevent instantiation

  /// Light theme configuration
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        primaryContainer: AppColors.primaryLight,
        secondary: AppColors.secondary,
        secondaryContainer: AppColors.secondaryLight,
        surface: AppColors.surface,
        background: AppColors.background,
        error: AppColors.error,
        onPrimary: AppColors.textOnPrimary,
        onSecondary: AppColors.textOnSecondary,
        onSurface: AppColors.textPrimary,
        onBackground: AppColors.textPrimary,
        onError: AppColors.textOnPrimary,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          fontSize: AppFonts.sizeXl,
          fontWeight: FontWeight.w600,
          fontFamily: AppFonts.primary,
          color: AppColors.textOnPrimary,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: AppFonts.size5xl,
          fontWeight: FontWeight.bold,
          fontFamily: AppFonts.primary,
          color: AppColors.textPrimary,
        ),
        displayMedium: TextStyle(
          fontSize: AppFonts.size4xl,
          fontWeight: FontWeight.bold,
          fontFamily: AppFonts.primary,
          color: AppColors.textPrimary,
        ),
        displaySmall: TextStyle(
          fontSize: AppFonts.size3xl,
          fontWeight: FontWeight.bold,
          fontFamily: AppFonts.primary,
          color: AppColors.textPrimary,
        ),
        headlineLarge: TextStyle(
          fontSize: AppFonts.size2xl,
          fontWeight: FontWeight.w600,
          fontFamily: AppFonts.primary,
          color: AppColors.textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: AppFonts.sizeXl,
          fontWeight: FontWeight.w600,
          fontFamily: AppFonts.primary,
          color: AppColors.textPrimary,
        ),
        headlineSmall: TextStyle(
          fontSize: AppFonts.sizeLg,
          fontWeight: FontWeight.w600,
          fontFamily: AppFonts.primary,
          color: AppColors.textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: AppFonts.sizeLg,
          fontWeight: FontWeight.w500,
          fontFamily: AppFonts.primary,
          color: AppColors.textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: AppFonts.sizeMd,
          fontWeight: FontWeight.w500,
          fontFamily: AppFonts.primary,
          color: AppColors.textPrimary,
        ),
        titleSmall: TextStyle(
          fontSize: AppFonts.sizeBase,
          fontWeight: FontWeight.w500,
          fontFamily: AppFonts.primary,
          color: AppColors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: AppFonts.sizeMd,
          fontWeight: FontWeight.normal,
          fontFamily: AppFonts.primary,
          color: AppColors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: AppFonts.sizeBase,
          fontWeight: FontWeight.normal,
          fontFamily: AppFonts.primary,
          color: AppColors.textPrimary,
        ),
        bodySmall: TextStyle(
          fontSize: AppFonts.sizeSm,
          fontWeight: FontWeight.normal,
          fontFamily: AppFonts.primary,
          color: AppColors.textSecondary,
        ),
        labelLarge: TextStyle(
          fontSize: AppFonts.sizeBase,
          fontWeight: FontWeight.w500,
          fontFamily: AppFonts.primary,
          color: AppColors.textPrimary,
        ),
        labelMedium: TextStyle(
          fontSize: AppFonts.sizeSm,
          fontWeight: FontWeight.w500,
          fontFamily: AppFonts.primary,
          color: AppColors.textPrimary,
        ),
        labelSmall: TextStyle(
          fontSize: AppFonts.sizeXs,
          fontWeight: FontWeight.w500,
          fontFamily: AppFonts.primary,
          color: AppColors.textSecondary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          elevation: 2,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingLg,
            vertical: AppConstants.spacingMd,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          ),
          textStyle: TextStyle(
            fontSize: AppFonts.sizeBase,
            fontWeight: FontWeight.w600,
            fontFamily: AppFonts.primary,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingLg,
            vertical: AppConstants.spacingMd,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          ),
          side: BorderSide(color: AppColors.primary),
          textStyle: TextStyle(
            fontSize: AppFonts.sizeBase,
            fontWeight: FontWeight.w600,
            fontFamily: AppFonts.primary,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingMd,
            vertical: AppConstants.spacingSm,
          ),
          textStyle: TextStyle(
            fontSize: AppFonts.sizeBase,
            fontWeight: FontWeight.w600,
            fontFamily: AppFonts.primary,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          borderSide: BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingMd,
          vertical: AppConstants.spacingMd,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),
    );
  }

  /// Dark theme configuration (for future use)
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primaryLight,
        primaryContainer: AppColors.primary,
        secondary: AppColors.secondaryLight,
        secondaryContainer: AppColors.secondary,
        surface: AppColors.surfaceDark,
        background: AppColors.backgroundDark,
        error: AppColors.error,
        onPrimary: AppColors.textOnPrimary,
        onSecondary: AppColors.textOnSecondary,
        onSurface: AppColors.textOnPrimary,
        onBackground: AppColors.textOnPrimary,
        onError: AppColors.textOnPrimary,
      ),
      scaffoldBackgroundColor: AppColors.backgroundDark,
      // Similar structure to light theme but with dark colors
    );
  }
}
