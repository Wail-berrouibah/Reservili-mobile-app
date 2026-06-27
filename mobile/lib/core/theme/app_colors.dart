import 'package:flutter/material.dart';

/// Reservili color palette — elegant green, gold, and creamy identity.
class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF1F5D3A);
  static const Color primaryDark = Color(0xFF164229);
  static const Color primaryLight = Color(0xFF2E7D50);

  static const Color accent = Color(0xFFC8A24A);
  static const Color accentLight = Color(0xFFE0C57E);

  // Surfaces
  static const Color background = Color(0xFFF7F1E5);
  static const Color card = Color(0xFFFFFAF0);
  static const Color surface = Color(0xFFFFFFFF);

  // Text
  static const Color textPrimary = Color(0xFF1F1F1A);
  static const Color textSecondary = Color(0xFF6B6B5E);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Reservation status
  static const Color pending = Color(0xFFC8A24A);
  static const Color confirmed = Color(0xFF1F5D3A);
  static const Color cancelled = Color(0xFFB23A3A);

  // Feedback
  static const Color success = Color(0xFF2E7D50);
  static const Color error = Color(0xFFB23A3A);

  // Borders & dividers
  static const Color border = Color(0xFFE6DECB);
  static const Color divider = Color(0xFFEDE6D6);
}
