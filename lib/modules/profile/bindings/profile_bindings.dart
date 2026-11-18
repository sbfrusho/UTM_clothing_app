import 'package:get/get.dart';

import '../view_models/address_view_model.dart';
import '../view_models/edit_profile_view_model.dart';

class EditProfileBinding extends Bindings {
  @override
  void dependencies() =>
      Get.lazyPut(() => EditProfileViewModel(Get.find(), Get.find()));
}

class AddressBinding extends Bindings {
  @override
  void dependencies() =>
      Get.lazyPut(() => AddressViewModel(Get.find(), Get.find()));
}
