import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../data/repositories/auth_repository.dart';

class ForgotPasswordViewModel extends GetxController {
  ForgotPasswordViewModel(this._authRepo);

  final AuthRepository _authRepo;

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final RxBool isLoading = false.obs;
  final RxBool emailSent = false.obs;

  @override
  void onInit() {
    super.onInit();
    final prefill = Get.arguments;
    if (prefill is String) emailController.text = prefill;
  }

  Future<void> sendResetLink() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    isLoading.value = true;
    try {
      await _authRepo.sendPasswordReset(emailController.text.trim());
      emailSent.value = true;
    } on AppException catch (e) {
      AppSnackbar.error(e.message);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}
