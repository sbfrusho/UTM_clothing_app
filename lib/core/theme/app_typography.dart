import 'package:flutter/material.dart';

/// Manrope for UI text; Playfair Display for brand and display headings.
abstract final class AppTypography {
  static const sans = 'Manrope';
  static const serif = 'PlayfairDisplay';

  static TextTheme textTheme(Color text, Color muted) {
    TextStyle s(
      double size,
      FontWeight w, {
      double? height,
      double ls = 0,
      Color? c,
    }) => TextStyle(
      fontFamily: sans,
      fontSize: size,
      fontWeight: w,
      height: height,
      letterSpacing: ls,
      color: c ?? text,
    );
    TextStyle serifStyle(double size, {double ls = -0.5}) => TextStyle(
      fontFamily: serif,
      fontSize: size,
      fontWeight: FontWeight.w700,
      height: 1.15,
      letterSpacing: ls,
      color: text,
    );

    return TextTheme(
      displayLarge: serifStyle(52),
      displayMedium: serifStyle(44),
      displaySmall: serifStyle(36),
      headlineLarge: serifStyle(32),
      headlineMedium: serifStyle(28),
      headlineSmall: serifStyle(24, ls: -0.3),
      titleLarge: s(20, FontWeight.w700, height: 1.3, ls: -0.2),
      titleMedium: s(16, FontWeight.w700, height: 1.35),
      titleSmall: s(14, FontWeight.w600, height: 1.35),
      bodyLarge: s(16, FontWeight.w500, height: 1.5),
      bodyMedium: s(14, FontWeight.w500, height: 1.45),
      bodySmall: s(12, FontWeight.w500, height: 1.4, c: muted),
      labelLarge: s(15, FontWeight.w700, ls: 0.1),
      labelMedium: s(12, FontWeight.w600, ls: 0.2),
      labelSmall: s(11, FontWeight.w600, ls: 0.4, c: muted),
    );
  }
}
