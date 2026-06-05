import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF1A73E8);
  static const Color primaryDark = Color(0xFF1557B0);
  static const Color primaryLight = Color(0xFFD2E3FC);

  static const Color background = Color(0xFFF4F6FA);
  static const Color surface = Colors.white;
  static const Color authBackground = Color(0xFF8C7B5E);

  static const Color textPrimary = Color(0xFF0D1B2A);
  static const Color textSecondary = Color(0xFF5F6368);
  static const Color textHint = Color(0xFFADB5BD);

  static const Color income = Color(0xFF34A853);
  static const Color incomeBg = Color(0xFFE6F4EA);
  static const Color expense = Color(0xFFEA4335);
  static const Color expenseBg = Color(0xFFFCE8E6);

  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFF1F3F4);

  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);

  static const Color balanceGradientStart = Color(0xFF1A73E8);
  static const Color balanceGradientEnd = Color(0xFF0D47A1);

  // can't be const because withValues isn't const
  static Color get shadowColor =>
      const Color(0xFF000000).withValues(alpha: 0.08);
}
