import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color deepBackground = Color(0xFF061A16);
  static const Color darkGreen = Color(0xFF0B2A23);
  static const Color softCard = Color(0xFF103C32);
  static const Color cardSecondary = Color(0xFF16483C);
  static const Color primaryGreen = Color(0xFF4CD58A);
  static const Color mediumGreen = Color(0xFF1F7A5C);
  static const Color softMint = Color(0xFFA7F3C5);
  static const Color textPrimary = Color(0xFFF2FFF8);
  static const Color textSecondary = Color(0xFFA8BDB4);
  static const Color textMuted = Color(0xFF6F8A80);
  static const Color lightSurface = Color(0xFFEEF7F1);
  static const Color borderSoft = Color(0xFF245B4B);
  static const Color danger = Color(0xFFE85D5D);
  static const Color warning = Color(0xFFEACB6B);

  // Backward compatibility mappings
  static const Color primaryDark = deepBackground;
  static const Color secondaryDark = darkGreen;
  static const Color cardDark = softCard;
  static const Color neonGreen = primaryGreen;
  static const Color softGreen = softMint;
  static const Color textWhite = textPrimary;
  static const Color textGray = textSecondary;
  static const Color borderGreen = borderSoft;

  static const Color primary = primaryGreen;
  static const Color secondary = mediumGreen;
  static const Color accent = softMint;

  static const Color background = deepBackground;
  static const Color surface = softCard;

  static const Color success = primaryGreen;
  static const Color error = danger;
  static const Color border = borderSoft;
}
