import 'package:get/get.dart';

import '../view_models/splash_view_model.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(SplashViewModel(Get.find(), Get.find(), Get.find()));
  }
}
