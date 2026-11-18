import 'dart:async';

import 'package:get/get.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/services/auth_service.dart';
import '../../../data/models/order_model.dart';
import '../../../data/repositories/order_repository.dart';

/// Live order history: status changes made by the shop appear at once.
class OrdersViewModel extends GetxController {
  OrdersViewModel(this._auth, this._orders);

  final AuthService _auth;
  final OrderRepository _orders;

  final RxList<OrderModel> orders = <OrderModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxnString error = RxnString();

  StreamSubscription<List<OrderModel>>? _sub;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    final uid = _auth.uid;
    if (uid == null) return;
    await _sub?.cancel();
    error.value = null;
    _sub = _orders
        .watchForCustomer(uid)
        .listen(
          (list) {
            orders.assignAll(list);
            isLoading.value = false;
          },
          onError: (Object e) {
            error.value = AppException.from(e).message;
            isLoading.value = false;
          },
        );
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
