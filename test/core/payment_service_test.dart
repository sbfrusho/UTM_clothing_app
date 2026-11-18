import 'package:flutter_test/flutter_test.dart';
import 'package:your_shop/core/config/app_config.dart';
import 'package:your_shop/core/services/payment/payment_gateway.dart';
import 'package:your_shop/core/services/payment/payment_service.dart';
import 'package:your_shop/core/utils/money.dart';
import 'package:your_shop/data/repositories/order_repository.dart';

class _FakeGateway implements PaymentGateway {
  _FakeGateway(this.result);

  final PaymentResult result;
  String? orderId;
  double? chargedAmount;
  String? chargedCurrency;

  @override
  String get id => 'fake';

  @override
  Future<PaymentResult> pay({
    required String orderId,
    required double amount,
    required String currency,
  }) async {
    this.orderId = orderId;
    chargedAmount = amount;
    chargedCurrency = currency;
    return result;
  }
}

class _FakeOrders extends Fake implements OrderRepository {
  final settled = <String, String>{};

  @override
  Future<void> markTestPaid(String orderId, String reference) async =>
      settled[orderId] = reference;
}

void main() {
  group('PaymentResult', () {
    test('only success counts as paid', () {
      expect(const PaymentResult.success().isSuccess, isTrue);
      expect(const PaymentResult.cancelled().isSuccess, isFalse);
      expect(const PaymentResult.failed('x').isSuccess, isFalse);
    });
  });

  group('PaymentService.payForOrder', () {
    test('pays the stored order in the configured currency', () async {
      final gateway = _FakeGateway(
        const PaymentResult.success(reference: 'pi_1', settledByServer: true),
      );
      final orders = _FakeOrders();
      final service = PaymentService(gateway: gateway, orders: orders);

      final result = await service.payForOrder('o1', 42.5);

      expect(result.isSuccess, isTrue);
      expect(gateway.orderId, 'o1');
      expect(gateway.chargedAmount, 42.5);
      expect(gateway.chargedCurrency, AppConfig.currency);
      // Server-settled payments are recorded by the webhook, not the app.
      expect(orders.settled, isEmpty);
    });

    test('test payments are recorded by the app', () async {
      final orders = _FakeOrders();
      final service = PaymentService(
        gateway: _FakeGateway(const PaymentResult.success(reference: 'demo_1')),
        orders: orders,
      );

      await service.payForOrder('o2', 10);

      expect(orders.settled, {'o2': 'demo_1'});
    });

    test('a cancelled payment records nothing', () async {
      final orders = _FakeOrders();
      final service = PaymentService(
        gateway: _FakeGateway(const PaymentResult.cancelled()),
        orders: orders,
      );

      final result = await service.payForOrder('o3', 10);

      expect(result.status, PaymentStatus.cancelled);
      expect(orders.settled, isEmpty);
    });

    test('uses the demo gateway when Stripe is not configured', () {
      expect(AppConfig.isStripeConfigured, isFalse);
      expect(PaymentService().gateway.id, 'demo');
      expect(PaymentService().isTestMode, isTrue);
    });
  });

  test('minor units match the server rounding', () {
    // Same cases as functions/test/rules.test.ts.
    expect(toMinorUnits(19.99), 1999);
    expect(toMinorUnits(0.1 + 0.2), 30);
    expect(toMinorUnits(1.005), 101);
  });
}
