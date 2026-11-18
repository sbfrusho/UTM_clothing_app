import 'package:get/get.dart';

import '../view_models/app_lock_view_model.dart';
import '../view_models/forgot_password_view_model.dart';
import '../view_models/login_view_model.dart';
import '../view_models/register_view_model.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() =>
      Get.lazyPut(() => LoginViewModel(Get.find(), Get.find()));
}

class RegisterBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(() => RegisterViewModel(Get.find()));
}

class ForgotPasswordBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(() => ForgotPasswordViewModel(Get.find()));
}

class AppLockBinding extends Bindings {
  @override
  void dependencies() =>
      Get.lazyPut(() => AppLockViewModel(Get.find(), Get.find()));
}
