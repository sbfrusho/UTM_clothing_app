import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/user_repository.dart';

class EditProfileViewModel extends GetxController {
  EditProfileViewModel(this._auth, this._users);

  final AuthService _auth;
  final UserRepository _users;

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;
  UserModel? _original;

  String get email => _auth.email ?? '';

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    final uid = _auth.uid;
    if (uid == null) return;
    try {
      _original = await _users.fetch(uid) ?? UserModel(uid: uid, email: email);
      nameController.text = _original!.name;
      phoneController.text = _original!.phone;
    } on AppException catch (e) {
      AppSnackbar.error(e.message);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> save() async {
    final original = _original;
    if (original == null || !(formKey.currentState?.validate() ?? false)) {
      return;
    }
    isSaving.value = true;
    try {
      await _users.updateProfile(
        original.copyWith(
          name: nameController.text.trim(),
          phone: phoneController.text.trim(),
        ),
      );
      Get.back();
      AppSnackbar.success('Profile updated.');
    } on AppException catch (e) {
      AppSnackbar.error(e.message);
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    super.onClose();
  }
}
