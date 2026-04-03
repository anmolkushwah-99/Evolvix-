import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFF0A0118);
  static const Color surface = Color(0xFF1A0F2E);
  static const Color primary = Color(0xFF9810FA);
  static const Color secondary = Color(0xFF4F39F6);
  static const Color accentCyan = Color(0xFF00D3F3);
  static const Color accentGold = Color(0xFFFDC700);
  static const Color accentGreen = Color(0xFF05DF72);
  static const Color accentPink = Color(0xFFF6339A);
  
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient xpGradient = LinearGradient(
    colors: [Color(0xFFAD46FF), Color(0xFFF6339A), Color(0xFF615FFF)],
    stops: [0.0, 0.5, 1.0],
  );
}
