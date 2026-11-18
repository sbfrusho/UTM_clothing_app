import 'package:flutter_test/flutter_test.dart';
import 'package:your_shop/core/config/app_config.dart';
import 'package:your_shop/core/services/payment/payment_gateway.dart';
import 'package:your_shop/core/services/payment/payment_service.dart';

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
  });

  group('PaymentService', () {
    test('charges the configured currency through the gateway', () async {
      final gateway = _FakeGateway(
        const PaymentResult.success(reference: 'pi_123'),
      );
      final service = PaymentService(gateway: gateway);

      final result = await service.pay(42.5);

      expect(result.isSuccess, isTrue);
      expect(result.reference, 'pi_123');
      expect(gateway.chargedAmount, 42.5);
      expect(gateway.chargedCurrency, AppConfig.currency);
    });

    test('a cancelled payment is reported as cancelled', () async {
      final service = PaymentService(
        gateway: _FakeGateway(const PaymentResult.cancelled()),
      );

      final result = await service.pay(10);

      expect(result.status, PaymentStatus.cancelled);
    });

    test('uses the demo gateway when Stripe is not configured', () {
      expect(AppConfig.isStripeConfigured, isFalse);
      expect(PaymentService().gateway.id, 'demo');
    });
  });
}
