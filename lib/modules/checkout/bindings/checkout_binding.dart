import 'package:get/get.dart';

import '../view_models/checkout_view_model.dart';
import '../view_models/order_success_view_model.dart';

class CheckoutBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => CheckoutViewModel(
        auth: Get.find(),
        addresses: Get.find(),
        orders: Get.find(),
        payments: Get.find(),
        cart: Get.find(),
      ),
    );
  }
}

class OrderSuccessBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(() => OrderSuccessViewModel(Get.find()));
}
