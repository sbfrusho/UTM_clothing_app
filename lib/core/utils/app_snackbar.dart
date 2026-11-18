import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Floating, theme-aware snackbars (charcoal on light, cream on dark).
abstract final class AppSnackbar {
  static void success(String message, {String title = 'Done'}) =>
      _show(title, message, Icons.check_circle_outline);

  static void error(String message, {String title = 'Something went wrong'}) =>
      _show(title, message, Icons.error_outline, isError: true);

  static void info(String message, {String title = 'Heads up'}) =>
      _show(title, message, Icons.info_outline);

  /// With a trailing action, e.g. "View cart".
  static void action(
    String title,
    String message, {
    required String actionLabel,
    required VoidCallback onAction,
  }) => _show(
    title,
    message,
    Icons.check_circle_outline,
    mainButton: TextButton(
      onPressed: () {
        Get.closeCurrentSnackbar();
        onAction();
      },
      child: Text(actionLabel.tr),
    ),
  );

  static void _show(
    String title,
    String message,
    IconData icon, {
    bool isError = false,
    TextButton? mainButton,
  }) {
    final scheme = Get.theme.colorScheme;
    final background = isError ? scheme.errorContainer : scheme.inverseSurface;
    final foreground = isError
        ? scheme.onErrorContainer
        : scheme.onInverseSurface;
    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
    Get.snackbar(
      title.tr,
      message.tr,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: background,
      colorText: foreground,
      icon: Icon(icon, color: foreground),
      borderRadius: 16,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
      duration: const Duration(seconds: 3),
      animationDuration: const Duration(milliseconds: 250),
      mainButton: mainButton == null
          ? null
          : TextButton(
              onPressed: mainButton.onPressed,
              style: TextButton.styleFrom(foregroundColor: foreground),
              child: mainButton.child!,
            ),
    );
  }
}
