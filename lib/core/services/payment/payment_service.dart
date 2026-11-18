import 'package:get/get.dart';

import '../../config/app_config.dart';
import 'demo_payment_gateway.dart';
import 'payment_gateway.dart';
import 'stripe_payment_gateway.dart';

/// Chooses the active gateway. Stripe is used only when a server-side
/// PaymentIntent backend is configured; otherwise the demo gateway runs.
class PaymentService extends GetxService {
  PaymentService({PaymentGateway? gateway})
    : gateway =
          gateway ??
          (AppConfig.isStripeConfigured
              ? StripePaymentGateway()
              : DemoPaymentGateway());

  final PaymentGateway gateway;

  Future<PaymentResult> pay(double amount) =>
      gateway.pay(amount: amount, currency: AppConfig.currency);
}
