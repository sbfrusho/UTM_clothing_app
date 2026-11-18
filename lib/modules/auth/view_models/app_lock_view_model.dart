import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/biometric_service.dart';

class AppLockViewModel extends GetxController {
  AppLockViewModel(this._auth, this._biometrics);

  final AuthService _auth;
  final BiometricService _biometrics;

  final RxBool isAuthenticating = false.obs;

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
    if (ok) Get.offAllNamed(AppRoutes.shell);
  }

  Future<void> useAnotherAccount() async {
    await _auth.signOut();
    Get.offAllNamed(AppRoutes.welcome);
  }
}
