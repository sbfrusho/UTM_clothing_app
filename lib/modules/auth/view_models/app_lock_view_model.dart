import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/biometric_service.dart';
import '../../../core/services/session_service.dart';
import '../../../data/repositories/auth_repository.dart';

class AppLockViewModel extends GetxController {
  AppLockViewModel(this._auth, this._authRepo, this._biometrics);

  final AuthService _auth;
  final AuthRepository _authRepo;
  final BiometricService _biometrics;

  final RxBool isAuthenticating = false.obs;

  /// Locked on resume: unlocking returns to the previous screen.
  final bool _isResume = Get.arguments == AppLockArgs.resume;

  String get email => _auth.email ?? '';

  @override
  void onReady() {
    super.onReady();
    unlock();
  }

  Future<void> unlock() async {
    if (isAuthenticating.value) return;
    isAuthenticating.value = true;
    final ok = await _biometrics.authenticate();
    isAuthenticating.value = false;
    if (!ok) return;
    if (_isResume) {
      Get.back<void>();
    } else {
      Get.offAllNamed<void>(AppRoutes.shell);
    }
  }

  /// Signing out ends the session; [SessionService] routes to welcome.
  Future<void> useAnotherAccount() => _authRepo.signOut();
}
