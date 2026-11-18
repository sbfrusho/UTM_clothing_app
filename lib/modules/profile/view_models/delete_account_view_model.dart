import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../data/repositories/auth_repository.dart';

/// Permanently deletes the account after confirming the user's identity
/// (password, or Google for Google-only accounts).
class DeleteAccountViewModel extends GetxController {
  DeleteAccountViewModel(this._auth, this._authRepo);

  final AuthService _auth;
  final AuthRepository _authRepo;

  final formKey = GlobalKey<FormState>();
  final passwordController = TextEditingController();

  final RxBool confirmed = false.obs;
  final RxBool isDeleting = false.obs;
  final RxBool obscurePassword = true.obs;

  /// Password accounts confirm with their password; others with Google.
  bool get usesPassword => _auth.hasPassword;
  String get email => _auth.email ?? '';

  bool get canSubmit => confirmed.value && !isDeleting.value;

  void toggleConfirmed(bool? value) => confirmed.value = value ?? false;
  void toggleObscure() => obscurePassword.toggle();

  String? validatePassword(String? value) =>
      (value ?? '').isEmpty ? 'Enter your password to continue.'.tr : null;

  Future<void> delete() async {
    if (!canSubmit) return;
    if (usesPassword && !(formKey.currentState?.validate() ?? false)) return;
    isDeleting.value = true;
    try {
      final ok = await _authRepo.reauthenticate(
        password: usesPassword ? passwordController.text : null,
      );
      if (!ok) return;
      await _authRepo.deleteAccount();
      // SessionService sends the user to the welcome screen.
      AppSnackbar.success('Your account has been deleted.');
    } on AppException catch (e) {
      AppSnackbar.error(e.message);
    } finally {
      isDeleting.value = false;
    }
  }

  @override
  void onClose() {
    passwordController.dispose();
    super.onClose();
  }
}
