import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/services/push_token_service.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/user_repository.dart';

class LoginViewModel extends GetxController {
  LoginViewModel(this._authRepo, this._users);

  final AuthRepository _authRepo;
  final UserRepository _users;

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool obscurePassword = true.obs;

  /// Shown after an unverified sign-in attempt.
  final RxBool needsVerification = false.obs;

  String get _email => emailController.text.trim();

  Future<void> signIn() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    isLoading.value = true;
    needsVerification.value = false;
    try {
      final user = await _authRepo.signIn(
        email: _email,
        password: passwordController.text,
      );

      if (!user.emailVerified) {
        await _authRepo.signOut();
        needsVerification.value = true;
        AppSnackbar.info(
          'Please verify your email before logging in.',
          title: 'Verify your email',
        );
        return;
      }

      final profile = await _users.fetch(user.uid);
      if (profile?.isAdmin ?? false) {
        await _authRepo.signOut();
        AppSnackbar.error('Admin accounts must use the admin app.');
        return;
      }

      final token = await PushTokenService.getToken();
      if (token != null) await _users.updateDeviceToken(user.uid, token);

      Get.offAllNamed(AppRoutes.shell);
    } on AppException catch (e) {
      AppSnackbar.error(e.message);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resendVerification() async {
    isLoading.value = true;
    try {
      await _authRepo.resendVerification(
        email: _email,
        password: passwordController.text,
      );
      AppSnackbar.success('Verification email sent to $_email.');
    } on AppException catch (e) {
      AppSnackbar.error(e.message);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
