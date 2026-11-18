import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Light / dark / system preference, persisted per device.
class ThemeService extends GetxService {
  static const _prefKey = 'theme_mode';

  final Rx<ThemeMode> mode = ThemeMode.system.obs;

  Future<ThemeService> init() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_prefKey);
    mode.value = ThemeMode.values.firstWhere(
      (m) => m.name == stored,
      orElse: () => ThemeMode.system,
    );
    return this;
  }

  Future<void> setMode(ThemeMode value) async {
    mode.value = value;
    Get.changeThemeMode(value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, value.name);
  }
}
