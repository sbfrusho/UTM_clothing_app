import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Semantic colors that Material's ColorScheme does not cover.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.success,
    required this.warning,
    required this.info,
    required this.accent,
    required this.mutedText,
    required this.skeleton,
    required this.imageBackground,
  });

  final Color success;
  final Color warning;
  final Color info;

  /// Sand accent for badges and highlights.
  final Color accent;
  final Color mutedText;
  final Color skeleton;

  /// Behind product photos (most have white/cream backgrounds).
  final Color imageBackground;

  static const light = AppPalette(
    success: AppColors.sage,
    warning: AppColors.ochre,
    info: AppColors.slate,
    accent: AppColors.sand,
    mutedText: AppColors.grey500,
    skeleton: AppColors.cream200,
    imageBackground: AppColors.cream200,
  );

  static const dark = AppPalette(
    success: AppColors.sageLight,
    warning: AppColors.ochreLight,
    info: AppColors.slateLight,
    accent: AppColors.sandDeep,
    mutedText: AppColors.grey400,
    skeleton: AppColors.night600,
    imageBackground: AppColors.night600,
  );

  @override
  AppPalette copyWith({
    Color? success,
    Color? warning,
    Color? info,
    Color? accent,
    Color? mutedText,
    Color? skeleton,
    Color? imageBackground,
  }) => AppPalette(
    success: success ?? this.success,
    warning: warning ?? this.warning,
    info: info ?? this.info,
    accent: accent ?? this.accent,
    mutedText: mutedText ?? this.mutedText,
    skeleton: skeleton ?? this.skeleton,
    imageBackground: imageBackground ?? this.imageBackground,
  );

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      mutedText: Color.lerp(mutedText, other.mutedText, t)!,
      skeleton: Color.lerp(skeleton, other.skeleton, t)!,
      imageBackground: Color.lerp(imageBackground, other.imageBackground, t)!,
    );
  }
}

extension AppPaletteX on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;
}
