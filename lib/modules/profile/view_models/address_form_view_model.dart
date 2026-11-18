import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../core/config/app_config.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../data/models/address_model.dart';
import '../../../data/repositories/address_repository.dart';
import '../../../data/repositories/user_repository.dart';

class AddressFormViewModel extends GetxController {
  AddressFormViewModel(this._auth, this._repo, this._users);

  final AuthService _auth;
  final AddressRepository _repo;
  final UserRepository _users;

  static const labels = ['Home', 'Work', 'Other'];

  /// Null when adding.
  final AddressModel? editing = Get.arguments is AddressModel
      ? Get.arguments as AddressModel
      : null;

  final formKey = GlobalKey<FormState>();
  final fullName = TextEditingController();
  final phone = TextEditingController();
  final address = TextEditingController();
  final street = TextEditingController();
  final city = TextEditingController();
  final state = TextEditingController();
  final postalCode = TextEditingController();
  final country = TextEditingController(text: AppConfig.defaultCountry);

  final RxString label = 'Home'.obs;
  final RxBool isDefault = false.obs;
  final RxBool isSaving = false.obs;

  bool get isEditing => editing != null;

  @override
  void onInit() {
    super.onInit();
    final a = editing;
    if (a != null) {
      label.value = a.label;
      fullName.text = a.fullName;
      phone.text = a.phone;
      address.text = a.address;
      street.text = a.street;
      city.text = a.city;
      state.text = a.state;
      postalCode.text = a.postalCode;
      country.text = a.country;
      isDefault.value = a.isDefault;
    } else {
      _prefillContact();
    }
  }

  Future<void> _prefillContact() async {
    final uid = _auth.uid;
    if (uid == null) return;
    try {
      final profile = await _users.fetch(uid);
      if (fullName.text.isEmpty) fullName.text = profile?.name ?? '';
      if (phone.text.isEmpty) phone.text = profile?.phone ?? '';
    } on AppException {
      // Optional prefill.
    }
  }

  Future<void> save() async {
    final uid = _auth.uid;
    if (uid == null || isSaving.value) return;
    if (!(formKey.currentState?.validate() ?? false)) return;
    isSaving.value = true;
    try {
      final saved = await _repo.save(
        uid,
        AddressModel(
          id: editing?.id,
          label: label.value,
          fullName: fullName.text.trim(),
          phone: phone.text.trim(),
          address: address.text.trim(),
          street: street.text.trim(),
          city: city.text.trim(),
          state: state.text.trim(),
          postalCode: postalCode.text.trim(),
          country: country.text.trim(),
          isDefault: isDefault.value,
        ),
      );
      Get.back<AddressModel>(result: saved);
    } on AppException catch (e) {
      AppSnackbar.error(e.message);
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    for (final c in [
      fullName,
      phone,
      address,
      street,
      city,
      state,
      postalCode,
      country,
    ]) {
      c.dispose();
    }
    super.onClose();
  }
}
