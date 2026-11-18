import 'package:get/get.dart';

import '../../../core/config/app_config.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/services/session_service.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../data/repositories/auth_repository.dart';

/// "Continue with Google", shared by the login and register screens.
class SocialSignInViewModel extends GetxController {
  SocialSignInViewModel(this._authRepo, this._session);

  final AuthRepository _authRepo;
  final SessionService _session;

  final RxBool isGoogleLoading = false.obs;

  bool get isGoogleAvailable => AppConfig.isGoogleSignInEnabled;

  Future<void> continueWithGoogle() async {
    if (isGoogleLoading.value) return;
    isGoogleLoading.value = true;
    try {
      final user = await _authRepo.signInWithGoogle();
      if (user == null) return; // cancelled
      Get.offAllNamed<void>(await _session.completeSignIn(user));
    } on AppException catch (e) {
      AppSnackbar.error(e.message);
    } finally {
      isGoogleLoading.value = false;
    }
  }
}
