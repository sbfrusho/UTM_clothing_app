import 'dart:ui';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../i18n/app_translations.dart';

/// App language (English or Bahasa Melayu), persisted per device.
/// `null` follows the phone's language.
class LanguageService extends GetxService {
  static const _prefKey = 'language';

  /// Language code chosen by the user, or `null` for the system language.
  final RxnString code = RxnString();

  /// Locale to start with: the saved choice or the supported system one.
  Locale get locale => AppTranslations.resolve(code.value, Get.deviceLocale);

  Future<LanguageService> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(_prefKey);
      code.value = AppTranslations.isSupported(stored) ? stored : null;
    } catch (_) {
      // Defaults to the system language.
    }
    return this;
  }

  Future<void> setLanguage(String? value) async {
    code.value = AppTranslations.isSupported(value) ? value : null;
    await Get.updateLocale(locale);
    try {
      final prefs = await SharedPreferences.getInstance();
      if (code.value == null) {
        await prefs.remove(_prefKey);
      } else {
        await prefs.setString(_prefKey, code.value!);
      }
    } catch (_) {
      // Applies for this session only.
    }
  }
}
