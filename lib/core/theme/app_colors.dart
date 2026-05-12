import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFF101010);
  static const backgroundAlt = Color(0xFF151311);
  static const surface = Color(0xFF1F1F1F);
  static const surfaceSoft = Color(0xFF292929);
  static const surfaceHigh = Color(0xFF333333);
  static const orange = Color(0xFFFF7417);
  static const orangeLight = Color(0xFFFFB28C);
  static const orangeDark = Color(0xFFB94E0D);
  static const peach = Color(0xFFFFC2A8);
  static const blue = Color(0xFF03A9F4);
  static const success = Color(0xFFFFB38F);
  static const danger = Color(0xFFFFA6A6);
  static const textPrimary = Color(0xFFF8F5F1);
  static const textSecondary = Color(0xFFD8C3B6);
  static const textMuted = Color(0xFF8C8580);
  static const divider = Color(0xFF302B28);

  static const orangeGradient = LinearGradient(
    colors: [orangeLight, orange],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
