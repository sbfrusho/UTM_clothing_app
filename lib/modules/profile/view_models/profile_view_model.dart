import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/biometric_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/theme_service.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/user_repository.dart';

class ProfileViewModel extends GetxController {
  ProfileViewModel(
    this._auth,
    this._users,
    this._authRepo,
    this._biometrics,
    this._theme,
  );

  final AuthService _auth;
  final UserRepository _users;
  final AuthRepository _authRepo;
  final BiometricService _biometrics;
  final ThemeService _theme;

  final Rxn<UserModel> user = Rxn<UserModel>();
  final RxBool isLoading = false.obs;

  RxBool get isAppLockEnabled => _biometrics.isLockEnabled;

  NotificationService get _notifications => Get.find<NotificationService>();
  bool get notificationsOn =>
      Get.isRegistered<NotificationService>() &&
      (_notifications.enabled.value ?? false);

  /// Android can't revoke a granted permission from the app, and won't
  /// prompt again after a denial, so both cases point to system settings.
  Future<void> setNotifications(bool on) async {
    if (on && !notificationsOn) {
      final ok = await _notifications.requestPermission();
      if (!ok) {
        AppSnackbar.info(
          'Allow notifications for Your Shop in your phone settings.',
          title: 'Notifications are off',
        );
      }
    } else if (!on && notificationsOn) {
      AppSnackbar.info(
        'Turn off notifications for Your Shop in your phone settings.',
        title: 'Notifications',
      );
    }
  }

  Rx<ThemeMode> get themeMode => _theme.mode;

  String get initials {
    final parts = displayName.trim().split(RegExp(r'\s+'));
    return parts.take(2).map((p) => p.isEmpty ? '' : p[0].toUpperCase()).join();
  }

  /// Google-only accounts have no password to reset.
  bool get canChangePassword => _auth.hasPassword;

  String get signInMethod => switch ((_auth.hasPassword, _auth.hasGoogle)) {
    (true, true) => 'Email and Google',
    (false, true) => 'Google',
    _ => 'Email and password',
  };

  Future<void> setThemeMode(ThemeMode mode) => _theme.setMode(mode);
  String get email => _auth.email ?? '';
  String get displayName {
    final name = user.value?.name ?? '';
    return name.isEmpty ? email.split('@').first : name;
  }

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    final uid = _auth.uid;
    if (uid == null) return;
    isLoading.value = true;
    try {
      user.value = await _users.fetch(uid);
    } on AppException catch (e) {
      AppSnackbar.error(e.message);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> openEditProfile() async {
    await Get.toNamed(AppRoutes.editProfile);
    load(); // pick up edits
  }

  Future<void> sendPasswordReset() async {
    try {
      await _authRepo.sendPasswordReset(email);
      AppSnackbar.success('Password reset link sent to $email.');
    } on AppException catch (e) {
      AppSnackbar.error(e.message);
    }
  }

  Future<void> setAppLock(bool enabled) async {
    final applied = await _biometrics.setLockEnabled(enabled);
    if (!applied && enabled) {
      AppSnackbar.info(
        'Biometrics are not available or were not confirmed.',
        title: 'App lock',
      );
    }
  }

  /// [SessionService] routes to the welcome screen once the session ends.
  Future<void> signOut() => _authRepo.signOut();
}
