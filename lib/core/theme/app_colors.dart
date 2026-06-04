import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color background = Color(0xFF0B1115);
  static const Color backgroundAlt = Color(0xFF101820);
  static const Color surface = Color(0xFF16222A);
  static const Color surfaceElevated = Color(0xFF1D2B34);
  static const Color border = Color(0xFF2D3F49);

  static const Color primary = Color(0xFF35D07F);
  static const Color mint = Color(0xFF7BE0AD);
  static const Color amber = Color(0xFFF5B85B);
  static const Color coral = Color(0xFFF06B5B);
  static const Color softBlue = Color(0xFF6EA8FE);
  static const Color purple = Color(0xFFA78BFA);
  static const Color gold = Color(0xFFF4C95D);

  static const Color textPrimary = Color(0xFFF4F7F5);
  static const Color textSecondary = Color(0xFFAEB8B3);
  static const Color textMuted = Color(0xFF7D8A84);
  static const Color lightSurface = Color(0xFFEEF7F1);
  static const Color danger = coral;
  static const Color success = primary;
  static const Color warning = amber;

  // Backward compatibility mappings for older UI files.
  static const Color deepBackground = background;
  static const Color darkGreen = backgroundAlt;
  static const Color softCard = surface;
  static const Color cardSecondary = surfaceElevated;
  static const Color primaryGreen = primary;
  static const Color mediumGreen = mint;
  static const Color softMint = mint;
  static const Color borderSoft = border;
  static const Color primaryDark = deepBackground;
  static const Color secondaryDark = darkGreen;
  static const Color cardDark = softCard;
  static const Color neonGreen = primaryGreen;
  static const Color softGreen = softMint;
  static const Color textWhite = textPrimary;
  static const Color textGray = textSecondary;
  static const Color borderGreen = borderSoft;

  static const Color secondary = softBlue;
  static const Color accent = purple;
  static const Color error = danger;
}
