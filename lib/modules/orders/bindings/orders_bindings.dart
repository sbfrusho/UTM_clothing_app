import 'package:get/get.dart';

import '../view_models/order_detail_view_model.dart';
import '../view_models/orders_view_model.dart';

class OrdersBinding extends Bindings {
  @override
  void dependencies() =>
      Get.lazyPut(() => OrdersViewModel(Get.find(), Get.find()));
}

class OrderDetailBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(
    () => OrderDetailViewModel(Get.find(), Get.arguments as String),
  );
}
