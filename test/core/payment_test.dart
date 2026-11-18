import 'package:flutter_test/flutter_test.dart';
import 'package:your_shop/controller/payment-controller.dart';
import 'package:your_shop/core/config/app_config.dart';
import 'package:your_shop/core/services/payment/payment_gateway.dart';

class _FakeGateway implements PaymentGateway {
  _FakeGateway(this.result);

  final PaymentResult result;
  double? chargedAmount;
  String? chargedCurrency;

  @override
  String get id => 'fake';

  @override
  Future<PaymentResult> pay({
    required double amount,
    required String currency,
  }) async {
    chargedAmount = amount;
    chargedCurrency = currency;
    return result;
  }
}

void main() {
  group('PaymentResult', () {
    test('only success counts as paid', () {
      expect(const PaymentResult.success().isSuccess, isTrue);
      expect(const PaymentResult.cancelled().isSuccess, isFalse);
      expect(const PaymentResult.failed('x').isSuccess, isFalse);
    });

    test('cancelled carries the cancelled status', () {
      expect(const PaymentResult.cancelled().status, PaymentStatus.cancelled);
    });
  });

  group('PaymentController', () {
    test('charges the configured currency through the gateway', () async {
      final gateway =
          _FakeGateway(const PaymentResult.success(reference: 'pi_123'));
      final controller = PaymentController(gateway: gateway);

      final result = await controller.makePayment(42.5);

      expect(result.isSuccess, isTrue);
      expect(result.reference, 'pi_123');
      expect(gateway.chargedAmount, 42.5);
      expect(gateway.chargedCurrency, AppConfig.currency);
    });

    test('a cancelled payment is reported as not successful', () async {
      final controller = PaymentController(
        gateway: _FakeGateway(const PaymentResult.cancelled()),
      );

      final result = await controller.makePayment(10);

      expect(result.isSuccess, isFalse);
      expect(result.status, PaymentStatus.cancelled);
    });

    test('falls back to the demo gateway when Stripe is not configured', () {
      expect(AppConfig.isStripeConfigured, isFalse);
      expect(PaymentController().gateway.id, 'demo');
    });
  });
}
