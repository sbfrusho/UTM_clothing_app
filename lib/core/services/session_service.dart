import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../data/repositories/user_repository.dart';
import '../errors/app_exception.dart';
import '../utils/app_logger.dart';
import 'auth_service.dart';
import 'biometric_service.dart';
import 'notification_service.dart';

/// Owns the signed-in session lifecycle:
///
/// * decides where a user goes after launch or sign-in
///   (verify email, app lock or the shell),
/// * sends everyone back to the welcome screen when the session ends
///   (sign-out, disabled account, revoked token), from any screen,
/// * re-locks the app when it returns from the background and the
///   biometric lock is on.
class SessionService extends GetxService with WidgetsBindingObserver {
  SessionService(this._auth, this._biometrics);

  final AuthService _auth;
  final BiometricService _biometrics;

  UserRepository get _users => Get.find<UserRepository>();

  /// How long the app may stay in the background before it locks again.
  static const relockAfter = Duration(seconds: 30);

  /// Routes reachable without a session.
  static const publicRoutes = {
    AppRoutes.splash,
    AppRoutes.welcome,
    AppRoutes.login,
    AppRoutes.register,
    AppRoutes.forgotPassword,
  };

  DateTime? _backgroundedAt;
  Worker? _authWorker;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _authWorker = ever<User?>(_auth.user, _onUserChanged);
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _authWorker?.dispose();
    super.onClose();
  }

  // ---------------------------------------------------------------------------
  // Routing decisions
  // ---------------------------------------------------------------------------

  /// Pure routing rule, kept separate so it can be unit tested.
  static String destinationFor({
    required bool signedIn,
    required bool emailVerified,
    required bool lockEnabled,
    required bool fromLaunch,
  }) {
    if (!signedIn) return AppRoutes.welcome;
    if (!emailVerified) return AppRoutes.verifyEmail;
    // The user just proved who they are, so only lock on a cold start.
    if (fromLaunch && lockEnabled) return AppRoutes.appLock;
    return AppRoutes.shell;
  }

  /// Route for a cold start. Never throws: offline users with a valid
  /// session still get in and data loads later.
  Future<String> resolveLaunchRoute() async {
    final user = _auth.currentUser;
    if (user != null && user.emailVerified) {
      try {
        await _rejectAdmin(user);
      } on AppException {
        return AppRoutes.welcome;
      } catch (e, st) {
        AppLogger.error('Profile check failed on launch', e, st);
      }
      unawaited(_registerDeviceToken(user.uid));
    }
    return destinationFor(
      signedIn: user != null,
      emailVerified: user?.emailVerified ?? false,
      lockEnabled: _biometrics.isLockEnabled.value,
      fromLaunch: true,
    );
  }

  /// Route after an interactive sign-in (email, Google, verified link).
  ///
  /// Throws [AppException] (and signs out) for admin accounts.
  Future<String> completeSignIn(User user) async {
    if (user.emailVerified) {
      await _rejectAdmin(user);
      unawaited(_registerDeviceToken(user.uid));
    }
    return destinationFor(
      signedIn: true,
      emailVerified: user.emailVerified,
      lockEnabled: _biometrics.isLockEnabled.value,
      fromLaunch: false,
    );
  }

  Future<void> _rejectAdmin(User user) async {
    final profile = await _users.fetch(user.uid);
    if (profile?.isAdmin ?? false) {
      await _auth.signOut();
      throw const AppException('Admin accounts must use the admin app.');
    }
  }

  Future<void> _registerDeviceToken(String uid) async {
    if (Get.isRegistered<NotificationService>()) {
      await Get.find<NotificationService>().attach(uid);
    }
  }

  // ---------------------------------------------------------------------------
  // Session end
  // ---------------------------------------------------------------------------

  void _onUserChanged(User? user) {
    if (user != null) return;
    // The lock belongs to the session; the next account opts in itself.
    if (_biometrics.isLockEnabled.value) _biometrics.setLockEnabled(false);
    if (!publicRoutes.contains(Get.currentRoute)) {
      Get.offAllNamed<void>(AppRoutes.welcome);
    }
  }

  // ---------------------------------------------------------------------------
  // Re-lock on resume
  // ---------------------------------------------------------------------------

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        _backgroundedAt ??= DateTime.now();
      case AppLifecycleState.resumed:
        final since = _backgroundedAt;
        _backgroundedAt = null;
        if (since != null &&
            DateTime.now().difference(since) >= relockAfter &&
            _shouldLock) {
          Get.toNamed<void>(AppRoutes.appLock, arguments: AppLockArgs.resume);
        }
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        break;
    }
  }

  bool get _shouldLock {
    final route = Get.currentRoute;
    return _biometrics.isLockEnabled.value &&
        (_auth.currentUser?.emailVerified ?? false) &&
        route != AppRoutes.appLock &&
        route != AppRoutes.verifyEmail &&
        !publicRoutes.contains(route);
  }
}

/// Argument for [AppRoutes.appLock]: unlocking pops back to the screen the
/// user was on instead of opening the shell.
abstract final class AppLockArgs {
  static const resume = 'resume';
}
