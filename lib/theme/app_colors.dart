import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0x0A0118FF); // Deep dark purple/black
  static const Color surface = Color(0xFF1A0F2E);
  static const Color primary = Color(0xFF9810FA); // Purple
  static const Color secondary = Color(0xFF4F39F6); // Blueish Purple
  static const Color accent = Color(0xFF00D3F3); // Cyan
  static const Color xpGold = Color(0xFFFDC700); // Gold for XP/Milestones
  static const Color success = Color(0xFF05DF72); // Green
  static const Color error = Color(0xFFFF6467); // Red
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFDAB2FF); // Light Lavender
  
  static const LinearGradient bgGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0A0118),
      Color(0xFF2A1544),
    ],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
  );
}
