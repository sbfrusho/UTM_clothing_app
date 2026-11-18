import 'dart:ui';

import 'package:get/get.dart';

import 'ms_translations.dart';

/// GetX translations. Keys are the English text itself, so a missing
/// translation falls back to readable English and `.tr` can wrap any
/// string. Shared widgets (top bars, buttons, snackbars, empty states,
/// validators) translate what they are given, so most screens only need
/// their strings added to [msTranslations].
///
/// To add a language: add its map, its locale to [locales] and a choice in
/// the Profile language dialog.
class AppTranslations extends Translations {
  static const english = Locale('en', 'US');
  static const malay = Locale('ms', 'MY');
  static const locales = [english, malay];

  static bool isSupported(String? code) =>
      locales.any((l) => l.languageCode == code);

  /// The saved [code], else the device language when supported, else
  /// English.
  static Locale resolve(String? code, Locale? device) {
    final wanted = code ?? device?.languageCode;
    return locales.firstWhere(
      (l) => l.languageCode == wanted,
      orElse: () => english,
    );
  }

  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': const {},
    'ms_MY': msTranslations,
  };
}
