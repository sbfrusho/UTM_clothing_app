import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/services/session_service.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../data/repositories/auth_repository.dart';

class LoginViewModel extends GetxController {
  LoginViewModel(this._authRepo, this._session);

  final AuthRepository _authRepo;
  final SessionService _session;

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool obscurePassword = true.obs;

  Future<void> signIn() async {
    if (isLoading.value) return;
    if (!(formKey.currentState?.validate() ?? false)) return;
    isLoading.value = true;
    try {
      final user = await _authRepo.signIn(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      // Unverified users continue on the verify-email screen.
      Get.offAllNamed<void>(await _session.completeSignIn(user));
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
