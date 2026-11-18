import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/biometric_service.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/user_repository.dart';

class ProfileViewModel extends GetxController {
  ProfileViewModel(this._auth, this._users, this._authRepo, this._biometrics);

  final AuthService _auth;
  final UserRepository _users;
  final AuthRepository _authRepo;
  final BiometricService _biometrics;

  final Rxn<UserModel> user = Rxn<UserModel>();
  final RxBool isLoading = false.obs;

  RxBool get isAppLockEnabled => _biometrics.isLockEnabled;
  String get email => _auth.email ?? '';
  String get displayName {
    final name = user.value?.name ?? '';
    return name.isEmpty ? email.split('@').first : name;
  }

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    final uid = _auth.uid;
    if (uid == null) return;
    isLoading.value = true;
    try {
      user.value = await _users.fetch(uid);
    } on AppException catch (e) {
      AppSnackbar.error(e.message);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> openEditProfile() async {
    await Get.toNamed(AppRoutes.editProfile);
    load(); // pick up edits
  }

  Future<void> sendPasswordReset() async {
    try {
      await _authRepo.sendPasswordReset(email);
      AppSnackbar.success('Password reset link sent to $email.');
    } on AppException catch (e) {
      AppSnackbar.error(e.message);
    }
  }

  Future<void> setAppLock(bool enabled) async {
    final applied = await _biometrics.setLockEnabled(enabled);
    if (!applied && enabled) {
      AppSnackbar.info(
        'Biometrics are not available or were not confirmed.',
        title: 'App lock',
      );
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    Get.offAllNamed(AppRoutes.welcome);
  }
}
