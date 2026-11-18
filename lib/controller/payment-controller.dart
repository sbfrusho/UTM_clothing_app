import 'package:get/get.dart';
import 'package:your_shop/core/config/app_config.dart';
import 'package:your_shop/core/services/payment/demo_payment_gateway.dart';
import 'package:your_shop/core/services/payment/payment_gateway.dart';
import 'package:your_shop/core/services/payment/stripe_payment_gateway.dart';

/// Chooses the active gateway. Stripe is used only when a server-side
/// PaymentIntent backend is configured; otherwise the demo gateway runs.
class PaymentController extends GetxController {
  PaymentController({PaymentGateway? gateway})
      : gateway = gateway ??
            (AppConfig.isStripeConfigured
                ? StripePaymentGateway()
                : DemoPaymentGateway());

  final PaymentGateway gateway;

  Future<PaymentResult> makePayment(double amount) =>
      gateway.pay(amount: amount, currency: AppConfig.currency);
}
