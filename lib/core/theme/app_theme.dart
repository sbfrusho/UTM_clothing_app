import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_palette.dart';
import 'app_typography.dart';

/// Radii and spacing shared by components.
abstract final class AppRadius {
  static const sm = 10.0;
  static const md = 14.0;
  static const lg = 20.0;
  static const xl = 28.0;
}

abstract final class AppTheme {
  static ThemeData get light => _build(
    brightness: Brightness.light,
    scheme: const ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.grey800,
      onPrimary: AppColors.cream50,
      primaryContainer: AppColors.cream300,
      onPrimaryContainer: AppColors.grey900,
      secondary: AppColors.grey600,
      onSecondary: AppColors.cream50,
      secondaryContainer: AppColors.cream200,
      onSecondaryContainer: AppColors.grey800,
      tertiary: AppColors.sandDeep,
      onTertiary: AppColors.cream50,
      tertiaryContainer: Color(0xFFEFE2CE),
      onTertiaryContainer: AppColors.grey900,
      error: AppColors.terracotta,
      onError: AppColors.cream50,
      errorContainer: Color(0xFFF5DCD7),
      onErrorContainer: Color(0xFF5B1F17),
      surface: AppColors.cream100,
      onSurface: AppColors.grey900,
      onSurfaceVariant: AppColors.grey500,
      surfaceContainerLowest: AppColors.cream50,
      surfaceContainerLow: AppColors.cream50,
      surfaceContainer: AppColors.cream50,
      surfaceContainerHigh: AppColors.cream200,
      surfaceContainerHighest: AppColors.cream300,
      outline: AppColors.grey300,
      outlineVariant: AppColors.cream300,
      shadow: Color(0x14000000),
      scrim: Color(0x66000000),
      inverseSurface: AppColors.grey800,
      onInverseSurface: AppColors.cream100,
      inversePrimary: AppColors.cream300,
    ),
    palette: AppPalette.light,
  );

  static ThemeData get dark => _build(
    brightness: Brightness.dark,
    scheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.cream200,
      onPrimary: AppColors.grey900,
      primaryContainer: AppColors.night500,
      onPrimaryContainer: AppColors.cream100,
      secondary: AppColors.grey400,
      onSecondary: AppColors.grey900,
      secondaryContainer: AppColors.night600,
      onSecondaryContainer: AppColors.cream200,
      tertiary: AppColors.sand,
      onTertiary: AppColors.grey900,
      tertiaryContainer: Color(0xFF4A4034),
      onTertiaryContainer: AppColors.cream100,
      error: AppColors.terracottaLight,
      onError: Color(0xFF4A1610),
      errorContainer: Color(0xFF5B2A22),
      onErrorContainer: Color(0xFFF5DCD7),
      surface: AppColors.night900,
      onSurface: AppColors.cream100,
      onSurfaceVariant: AppColors.grey400,
      surfaceContainerLowest: AppColors.night900,
      surfaceContainerLow: AppColors.night800,
      surfaceContainer: AppColors.night800,
      surfaceContainerHigh: AppColors.night700,
      surfaceContainerHighest: AppColors.night600,
      outline: AppColors.night500,
      outlineVariant: AppColors.night600,
      shadow: Color(0x66000000),
      scrim: Color(0x99000000),
      inverseSurface: AppColors.cream100,
      onInverseSurface: AppColors.grey900,
      inversePrimary: AppColors.grey700,
    ),
    palette: AppPalette.dark,
  );

  static ThemeData _build({
    required Brightness brightness,
    required ColorScheme scheme,
    required AppPalette palette,
  }) {
    final isDark = brightness == Brightness.dark;
    final text = AppTypography.textTheme(scheme.onSurface, palette.mutedText);
    final overlay =
        (isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
            .copyWith(statusBarColor: Colors.transparent);
    final rounded = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      fontFamily: AppTypography.sans,
      textTheme: text,
      extensions: [palette],
      scaffoldBackgroundColor: scheme.surface,
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,

      // Modern, flat top bar: same color as the page, no tint, a hairline
      // shadow only once content scrolls under it.
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0.6,
        shadowColor: scheme.outline,
        centerTitle: false,
        titleSpacing: 20,
        toolbarHeight: 64,
        systemOverlayStyle: overlay,
        titleTextStyle: text.titleLarge,
        iconTheme: IconThemeData(color: scheme.onSurface, size: 22),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        hintStyle: text.bodyMedium?.copyWith(color: palette.mutedText),
        labelStyle: text.bodyMedium?.copyWith(color: palette.mutedText),
        floatingLabelStyle: text.bodyMedium?.copyWith(color: scheme.onSurface),
        prefixIconColor: palette.mutedText,
        suffixIconColor: palette.mutedText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: scheme.primary, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: scheme.error, width: 1.4),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          shape: rounded,
          textStyle: text.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          shape: rounded,
          foregroundColor: scheme.onSurface,
          side: BorderSide(color: scheme.outline),
          textStyle: text.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.onSurface,
          textStyle: text.labelLarge?.copyWith(
            decoration: TextDecoration.underline,
            decorationColor: scheme.outline,
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: scheme.onSurface),
      ),

      cardTheme: CardThemeData(
        color: scheme.surfaceContainerLowest,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: scheme.secondary,
        titleTextStyle: text.titleSmall,
        subtitleTextStyle: text.bodySmall,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      ),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant, space: 1),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainerLowest,
        selectedColor: scheme.primary,
        labelStyle: text.labelLarge,
        secondaryLabelStyle: text.labelLarge?.copyWith(color: scheme.onPrimary),
        side: BorderSide(color: scheme.outline),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        showCheckmark: false,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 68,
        elevation: 0,
        backgroundColor: scheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.primaryContainer,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => text.labelMedium?.copyWith(
            color: states.contains(WidgetState.selected)
                ? scheme.onSurface
                : palette.mutedText,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 24,
            color: states.contains(WidgetState.selected)
                ? scheme.onSurface
                : palette.mutedText,
          ),
        ),
      ),
      badgeTheme: BadgeThemeData(
        backgroundColor: scheme.primary,
        textColor: scheme.onPrimary,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? scheme.onPrimary
              : palette.mutedText,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? scheme.primary
              : scheme.surfaceContainerHighest,
        ),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStatePropertyAll(scheme.primary),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.surfaceContainerHighest,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        titleTextStyle: text.titleLarge,
        contentTextStyle: text.bodyMedium,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
        ),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: scheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        headerBackgroundColor: scheme.primary,
        headerForegroundColor: scheme.onPrimary,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: text.bodyMedium?.copyWith(
          color: scheme.onInverseSurface,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
