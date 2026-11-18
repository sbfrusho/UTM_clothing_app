import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/services/push_token_service.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../data/repositories/auth_repository.dart';

class RegisterViewModel extends GetxController {
  RegisterViewModel(this._authRepo);

  final AuthRepository _authRepo;

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool obscurePassword = true.obs;

  String? confirmPassword(String? value) =>
      value != passwordController.text ? 'Passwords do not match' : null;

  Future<void> register() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    isLoading.value = true;
    try {
      final email = emailController.text.trim();
      await _authRepo.register(
        name: nameController.text.trim(),
        email: email,
        phone: phoneController.text.trim(),
        password: passwordController.text,
        deviceToken: await PushTokenService.getToken(),
      );
      AppSnackbar.success(
        'We sent a verification link to $email. Verify it, then log in.',
        title: 'Account created',
      );
      Get.offNamed(AppRoutes.login);
    } on AppException catch (e) {
      AppSnackbar.error(e.message);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.onClose();
  }
}
