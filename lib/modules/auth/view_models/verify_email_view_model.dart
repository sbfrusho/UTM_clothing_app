import 'dart:async';

import 'package:get/get.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/session_service.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../data/repositories/auth_repository.dart';

/// Email verification gate. The user is signed in but unverified; the
/// screen checks the server every few seconds and continues on its own
/// once the link has been opened.
class VerifyEmailViewModel extends GetxController {
  VerifyEmailViewModel(this._auth, this._authRepo, this._session);

  final AuthService _auth;
  final AuthRepository _authRepo;
  final SessionService _session;

  static const pollEvery = Duration(seconds: 5);
  static const resendCooldown = 60;

  final RxBool isChecking = false.obs;
  final RxBool isSending = false.obs;

  /// Seconds until the link can be sent again; 0 means now.
  final RxInt cooldown = 0.obs;

  Timer? _poll;
  Timer? _cooldownTimer;
  bool _done = false;

  String get email => _auth.email ?? '';

  @override
  void onInit() {
    super.onInit();
    // Registration has just sent a link.
    if (Get.arguments == VerifyEmailArgs.justSent) _startCooldown();
    _poll = Timer.periodic(pollEvery, (_) => check(silent: true));
  }

  Future<void> check({bool silent = false}) async {
    if (isChecking.value || _done) return;
    isChecking.value = !silent;
    try {
      final verified = await _authRepo.reloadAndCheckVerified();
      if (verified) {
        final user = _auth.currentUser;
        if (user == null) return;
        _done = true;
        _poll?.cancel();
        if (!silent) AppSnackbar.success('Email verified. Welcome!');
        Get.offAllNamed<void>(await _session.completeSignIn(user));
      } else if (!silent) {
        AppSnackbar.info(
          'We could not confirm it yet. Open the link in the email, then '
          'try again.',
          title: 'Not verified yet',
        );
      }
    } on AppException catch (e) {
      if (!silent) AppSnackbar.error(e.message);
    } finally {
      isChecking.value = false;
    }
  }

  Future<void> resend() async {
    if (cooldown.value > 0 || isSending.value) return;
    isSending.value = true;
    try {
      await _authRepo.sendVerificationEmail();
      AppSnackbar.success('Verification email sent to $email.');
      _startCooldown();
    } on AppException catch (e) {
      AppSnackbar.error(e.message);
    } finally {
      isSending.value = false;
    }
  }

  /// Signing out ends the session; [SessionService] routes to welcome.
  Future<void> useAnotherAccount() async {
    _poll?.cancel();
    await _authRepo.signOut();
  }

  void _startCooldown() {
    cooldown.value = resendCooldown;
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (cooldown.value <= 1) {
        cooldown.value = 0;
        t.cancel();
      } else {
        cooldown.value--;
      }
    });
  }

  @override
  void onClose() {
    _poll?.cancel();
    _cooldownTimer?.cancel();
    super.onClose();
  }
}

abstract final class VerifyEmailArgs {
  static const justSent = 'just-sent';
}
