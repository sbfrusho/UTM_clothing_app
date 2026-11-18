import 'package:flutter/material.dart';

/// Brand palette. Sprint 3 expands this into full light/dark tokens.
abstract final class AppColors {
  static const primary = Color(0xFF6C0201);
  static const primaryBright = Color(0xFFFF0000);
  static const background = Color(0xFFF8F6F2);
  static const success = Color(0xFF2E7D32);
  static const warning = Color(0xFFED6C02);

  static const primaryGradient = LinearGradient(
    colors: [primary, primaryBright],
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
  );
}
