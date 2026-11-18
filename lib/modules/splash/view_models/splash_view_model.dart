import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/biometric_service.dart';
import '../../../core/utils/app_logger.dart';
import '../../../data/repositories/user_repository.dart';

/// Decides the first screen: welcome, app lock or the main shell.
class SplashViewModel extends GetxController {
  SplashViewModel(this._auth, this._users, this._biometrics);

  final AuthService _auth;
  final UserRepository _users;
  final BiometricService _biometrics;

  static const _minimumDisplay = Duration(milliseconds: 1200);

  @override
  void onReady() {
    super.onReady();
    _route();
  }

  Future<void> _route() async {
    final started = DateTime.now();
    final next = await _resolveRoute();
    final elapsed = DateTime.now().difference(started);
    if (elapsed < _minimumDisplay) {
      await Future<void>.delayed(_minimumDisplay - elapsed);
    }
    Get.offAllNamed(next);
  }

  Future<String> _resolveRoute() async {
    final user = _auth.currentUser;
    if (user == null || !user.emailVerified) return AppRoutes.welcome;

    try {
      final profile = await _users.fetch(user.uid);
      if (profile?.isAdmin ?? false) {
        // Admins use the separate admin app.
        await _auth.signOut();
        return AppRoutes.welcome;
      }
    } catch (e, st) {
      // Offline etc.: let a verified user in; data loads later.
      AppLogger.error('Profile check failed on launch', e, st);
    }

    return _biometrics.isLockEnabled.value
        ? AppRoutes.appLock
        : AppRoutes.shell;
  }
}
