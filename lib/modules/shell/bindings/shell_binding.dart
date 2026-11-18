import 'package:get/get.dart';

import '../../catalog/view_models/categories_view_model.dart';
import '../../home/view_models/home_view_model.dart';
import '../../profile/view_models/profile_view_model.dart';
import '../view_models/shell_view_model.dart';

/// The shell owns its tab view models; cart and wishlist are app-wide.
class ShellBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ShellViewModel());
    Get.lazyPut(() => HomeViewModel(Get.find()));
    Get.lazyPut(() => CategoriesViewModel(Get.find()));
    Get.lazyPut(
      () => ProfileViewModel(Get.find(), Get.find(), Get.find(), Get.find()),
    );
  }
}
