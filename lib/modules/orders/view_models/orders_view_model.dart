import 'package:get/get.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/services/auth_service.dart';
import '../../../data/models/order_model.dart';
import '../../../data/repositories/order_repository.dart';

class OrdersViewModel extends GetxController {
  OrdersViewModel(this._auth, this._orders);

  final AuthService _auth;
  final OrderRepository _orders;

  final RxList<OrderModel> orders = <OrderModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxnString error = RxnString();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    final uid = _auth.uid;
    if (uid == null) return;
    isLoading.value = true;
    error.value = null;
    try {
      orders.assignAll(await _orders.fetchForCustomer(uid));
    } on AppException catch (e) {
      error.value = e.message;
    } finally {
      isLoading.value = false;
    }
  }
}
