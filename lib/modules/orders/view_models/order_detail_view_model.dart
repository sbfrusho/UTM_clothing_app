import 'dart:async';

import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/payment/payment_gateway.dart';
import '../../../core/services/payment/payment_service.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../data/models/order_model.dart';
import '../../../data/repositories/order_repository.dart';

class OrderDetailViewModel extends GetxController {
  OrderDetailViewModel(this._orders, this._auth, this._payments, this.orderId);

  final OrderRepository _orders;
  final AuthService _auth;
  final PaymentService _payments;
  final String orderId;

  final Rxn<OrderModel> order = Rxn<OrderModel>();
  final RxBool isLoading = true.obs;
  final RxBool isBusy = false.obs;
  final RxnString error = RxnString();

  StreamSubscription<OrderModel?>? _sub;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    await _sub?.cancel();
    error.value = null;
    _sub = _orders
        .watchOrder(orderId)
        .listen(
          (o) {
            order.value = o;
            if (o == null) error.value = 'Order not found.';
            isLoading.value = false;
          },
          onError: (Object e) {
            error.value = AppException.from(e).message;
            isLoading.value = false;
          },
        );
  }

  /// Retry payment for a reserved card order.
  Future<void> pay() async {
    final o = order.value;
    if (o == null || !o.isAwaitingPayment || isBusy.value) return;
    isBusy.value = true;
    try {
      final result = await _payments.payForOrder(o.id, o.totalPrice);
      switch (result.status) {
        case PaymentStatus.success:
          Get.offNamed<void>(AppRoutes.orderSuccess, arguments: o.id);
        case PaymentStatus.cancelled:
          break;
        case PaymentStatus.failed:
          AppSnackbar.error(result.message ?? 'Payment failed.');
      }
    } finally {
      isBusy.value = false;
    }
  }

  Future<void> cancel() async {
    final uid = _auth.uid;
    final o = order.value;
    if (uid == null || o == null || !o.canCancel || isBusy.value) return;
    isBusy.value = true;
    try {
      await _orders.cancel(o.id, uid: uid);
      AppSnackbar.success(
        o.paymentStatus == PaymentStatusValue.paid
            ? 'Order cancelled and the test payment refunded.'
            : 'Order cancelled.',
      );
    } on AppException catch (e) {
      AppSnackbar.error(e.message);
    } finally {
      isBusy.value = false;
    }
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
