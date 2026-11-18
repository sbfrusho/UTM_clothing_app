import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../data/repositories/auth_repository.dart';
import 'verify_email_view_model.dart';

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
    if (isLoading.value) return;
    if (!(formKey.currentState?.validate() ?? false)) return;
    isLoading.value = true;
    try {
      await _authRepo.register(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        password: passwordController.text,
      );
      Get.offAllNamed<void>(
        AppRoutes.verifyEmail,
        arguments: VerifyEmailArgs.justSent,
      );
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
