import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme/app_colors.dart';

abstract final class AppSnackbar {
  static void success(String message, {String title = 'Success'}) =>
      _show(title, message, AppColors.success);

  static void error(String message, {String title = 'Error'}) =>
      _show(title, message, Colors.red.shade700);

  static void info(String message, {String title = 'Info'}) =>
      _show(title, message, Colors.black87);

  static void _show(String title, String message, Color color) {
    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: color,
      colorText: Colors.white,
      margin: const EdgeInsets.all(12),
      duration: const Duration(seconds: 3),
    );
  }
}
