import 'package:flutter/material.dart';

/// Centralized color constants for the app
/// Change colors here to update the entire app theme
class AppColors {
  AppColors._(); // Private constructor to prevent instantiation

  // Primary Colors
  static const Color primary = Color(0xFF1B5E20); // Deep green
  static const Color primaryLight = Color(0xFF4CAF50);
  static const Color primaryDark = Color(0xFF0D3E10);

  // Secondary Colors
  static const Color secondary = Color(0xFFF9A825); // Gold/Amber
  static const Color secondaryLight = Color(0xFFFFC107);
  static const Color secondaryDark = Color(0xFFF57F17);

  // Background Colors
  static const Color background = Color(0xFFF5F5F5);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);

  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textDisabled = Color(0xFFBDBDBD);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnSecondary = Color(0xFF212121);

  // Accent Colors
  static const Color accent = Color(0xFF00BCD4);
  static const Color error = Color(0xFFD32F2F);
  static const Color warning = Color(0xFFFF9800);
  static const Color success = Color(0xFF388E3C);
  static const Color info = Color(0xFF1976D2);

  // Border Colors
  static const Color border = Color(0xFFE0E0E0);
  static const Color borderDark = Color(0xFF424242);

  // Divider Colors
  static const Color divider = Color(0xFFE0E0E0);
  static const Color dividerDark = Color(0xFF424242);

  // Overlay Colors
  static const Color overlay = Color(0x80000000); // 50% black overlay
  static const Color overlayLight = Color(0x40000000); // 25% black overlay

  // Lock Screen Colors
  static const Color lockScreenBackground = Color(0xFF1B1B1B);
  static const Color lockScreenText = Color(0xFFFFFFFF);
  static const Color lockScreenAccent = Color(0xFF4CAF50);
}
