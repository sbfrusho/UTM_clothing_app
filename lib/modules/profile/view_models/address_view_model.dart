import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../data/models/address_model.dart';
import '../../../data/repositories/address_repository.dart';

class AddressViewModel extends GetxController {
  AddressViewModel(this._auth, this._addresses);

  final AuthService _auth;
  final AddressRepository _addresses;

  final formKey = GlobalKey<FormState>();
  final addressController = TextEditingController();
  final streetController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final postalCodeController = TextEditingController();
  final countryController = TextEditingController();

  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;
  String? _existingId;

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    final email = _auth.email;
    if (email == null) return;
    try {
      final existing = await _addresses.fetchForUser(email);
      if (existing != null) {
        _existingId = existing.id;
        addressController.text = existing.address;
        streetController.text = existing.street;
        cityController.text = existing.city;
        stateController.text = existing.state;
        postalCodeController.text = existing.postalCode;
        countryController.text = existing.country;
      }
    } on AppException catch (e) {
      AppSnackbar.error(e.message);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> save() async {
    final email = _auth.email;
    final uid = _auth.uid;
    if (email == null || uid == null) return;
    if (!(formKey.currentState?.validate() ?? false)) return;
    isSaving.value = true;
    try {
      final saved = await _addresses.save(
        AddressModel(
          id: _existingId,
          email: email,
          address: addressController.text.trim(),
          street: streetController.text.trim(),
          city: cityController.text.trim(),
          state: stateController.text.trim(),
          postalCode: postalCodeController.text.trim(),
          country: countryController.text.trim(),
        ),
        uid: uid,
      );
      _existingId = saved.id;
      Get.back(result: saved);
      AppSnackbar.success('Address saved.');
    } on AppException catch (e) {
      AppSnackbar.error(e.message);
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    for (final c in [
      addressController,
      streetController,
      cityController,
      stateController,
      postalCodeController,
      countryController,
    ]) {
      c.dispose();
    }
    super.onClose();
  }
}
