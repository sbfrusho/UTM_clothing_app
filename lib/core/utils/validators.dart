import 'package:get/get.dart';

/// Form validators: each returns an error message or `null`.
abstract final class Validators {
  static final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final _phone = RegExp(r'^\+?[0-9 \-]{7,15}$');

  static String? required(String? value, {String field = 'This field'}) =>
      (value == null || value.trim().isEmpty)
      ? '@field is required'.trParams({'field': field.tr})
      : null;

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required'.tr;
    return _email.hasMatch(value.trim()) ? null : 'Enter a valid email'.tr;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required'.tr;
    if (value.length < 8) return 'Use at least 8 characters'.tr;
    if (!value.contains(RegExp('[A-Za-z]')) ||
        !value.contains(RegExp('[0-9]'))) {
      return 'Use letters and numbers'.tr;
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Phone is required'.tr;
    return _phone.hasMatch(value.trim())
        ? null
        : 'Enter a valid phone number'.tr;
  }
}
