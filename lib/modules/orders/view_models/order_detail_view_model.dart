import 'package:get/get.dart';

import '../../../core/errors/app_exception.dart';
import '../../../data/models/order_model.dart';
import '../../../data/repositories/order_repository.dart';

class OrderDetailViewModel extends GetxController {
  OrderDetailViewModel(this._orders, this.orderId);

  final OrderRepository _orders;
  final String orderId;

  final Rxn<OrderModel> order = Rxn<OrderModel>();
  final RxBool isLoading = true.obs;
  final RxnString error = RxnString();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    error.value = null;
    try {
      order.value = await _orders.fetchOrder(orderId);
      if (order.value == null) error.value = 'Order not found.';
    } on AppException catch (e) {
      error.value = e.message;
    } finally {
      isLoading.value = false;
    }
  }
}
