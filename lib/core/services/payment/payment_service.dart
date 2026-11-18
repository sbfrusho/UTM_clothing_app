import 'package:get/get.dart';

import '../../../data/repositories/order_repository.dart';
import '../../config/app_config.dart';
import '../../errors/app_exception.dart';
import 'demo_payment_gateway.dart';
import 'payment_gateway.dart';
import 'stripe_payment_gateway.dart';

/// Chooses the active gateway and pays for stored orders. Stripe is used
/// only when the server backend is configured; otherwise the demo gateway.
class PaymentService extends GetxService {
  PaymentService({PaymentGateway? gateway, OrderRepository? orders})
    : gateway =
          gateway ??
          (AppConfig.isStripeConfigured
              ? StripePaymentGateway()
              : DemoPaymentGateway()),
      _ordersOverride = orders;

  final PaymentGateway gateway;
  final OrderRepository? _ordersOverride;

  OrderRepository get _orders => _ordersOverride ?? Get.find<OrderRepository>();

  String get gatewayId => gateway.id;
  bool get isTestMode => !AppConfig.isStripeConfigured;

  /// Pays for [orderId] and, for test payments, records the result.
  /// Real payments are recorded by the server webhook.
  Future<PaymentResult> payForOrder(String orderId, double amount) async {
    final result = await gateway.pay(
      orderId: orderId,
      amount: amount,
      currency: AppConfig.currency,
    );
    if (result.isSuccess && !result.settledByServer) {
      try {
        await _orders.markTestPaid(orderId, result.reference ?? 'test');
      } on AppException catch (e) {
        return PaymentResult.failed(e.message);
      }
    }
    return result;
  }
}
