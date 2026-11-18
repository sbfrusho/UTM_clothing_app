import 'package:get/get.dart';

import '../view_models/address_book_view_model.dart';
import '../view_models/address_form_view_model.dart';
import '../view_models/delete_account_view_model.dart';
import '../view_models/edit_profile_view_model.dart';

class EditProfileBinding extends Bindings {
  @override
  void dependencies() =>
      Get.lazyPut(() => EditProfileViewModel(Get.find(), Get.find()));
}

class AddressBookBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(
    () => AddressBookViewModel(Get.find(), Get.find(), Get.find()),
  );
}

class AddressFormBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(
    () => AddressFormViewModel(Get.find(), Get.find(), Get.find()),
  );
}

class DeleteAccountBinding extends Bindings {
  @override
  void dependencies() =>
      Get.lazyPut(() => DeleteAccountViewModel(Get.find(), Get.find()));
}
