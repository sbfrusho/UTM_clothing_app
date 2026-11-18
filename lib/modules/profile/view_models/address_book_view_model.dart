import 'dart:async';

import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../data/models/address_model.dart';
import '../../../data/repositories/address_repository.dart';
import '../../../data/repositories/user_repository.dart';

/// Arguments for [AppRoutes.address].
abstract final class AddressBookArgs {
  /// Opened from checkout: tapping an address returns it.
  static const select = 'select';
}

class AddressBookViewModel extends GetxController {
  AddressBookViewModel(this._auth, this._repo, this._users);

  final AuthService _auth;
  final AddressRepository _repo;
  final UserRepository _users;

  final RxList<AddressModel> addresses = <AddressModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxnString error = RxnString();
  final bool isSelecting = Get.arguments == AddressBookArgs.select;

  StreamSubscription<List<AddressModel>>? _sub;

  @override
  void onInit() {
    super.onInit();
    _start();
  }

  Future<void> _start() async {
    final uid = _auth.uid;
    final email = _auth.email;
    if (uid == null) return;
    if (email != null) {
      try {
        final profile = await _users.fetch(uid);
        await _repo.migrateLegacy(
          uid: uid,
          email: email,
          fullName: profile?.name ?? '',
          phone: profile?.phone ?? '',
        );
      } on AppException catch (e) {
        AppLogger.error('Address migration skipped', e);
      }
    }
    _sub = _repo
        .watch(uid)
        .listen(
          (list) {
            addresses.assignAll(list);
            isLoading.value = false;
          },
          onError: (Object e) {
            error.value = AppException.from(e).message;
            isLoading.value = false;
          },
        );
  }

  void onTap(AddressModel a) =>
      isSelecting ? Get.back<AddressModel>(result: a) : edit(a);

  Future<void> add() async {
    final saved = await Get.toNamed<AddressModel>(AppRoutes.addressForm);
    // A new address added while choosing one is the obvious choice.
    if (saved != null && isSelecting) Get.back<AddressModel>(result: saved);
  }

  Future<void> edit(AddressModel a) =>
      Get.toNamed<void>(AppRoutes.addressForm, arguments: a) ?? Future.value();

  Future<void> makeDefault(AddressModel a) async {
    final uid = _auth.uid;
    if (uid == null || a.id == null || a.isDefault) return;
    try {
      await _repo.setDefault(uid, a.id!);
    } on AppException catch (e) {
      AppSnackbar.error(e.message);
    }
  }

  Future<void> delete(AddressModel a) async {
    final uid = _auth.uid;
    if (uid == null || a.id == null) return;
    try {
      await _repo.delete(uid, a);
      AppSnackbar.info('Address deleted.');
    } on AppException catch (e) {
      AppSnackbar.error(e.message);
    }
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
