import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'payment_gateway.dart';

/// Simulated card payment used until a real gateway backend is deployed.
/// No money moves and no network call is made.
class DemoPaymentGateway implements PaymentGateway {
  @override
  String get id => 'demo';

  @override
  Future<PaymentResult> pay({
    required double amount,
    required String currency,
  }) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        icon: const Icon(Icons.science_outlined),
        title: const Text('Test payment'),
        content: Text(
          'Card payments are in test mode.\n'
          'You will be charged ${amount.toStringAsFixed(2)} $currency '
          '(simulated, no money is taken).',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Pay'),
          ),
        ],
      ),
      barrierDismissible: false,
    );

    if (confirmed != true) return const PaymentResult.cancelled();
    await Future<void>.delayed(const Duration(milliseconds: 800));
    return PaymentResult.success(
      reference: 'demo_${DateTime.now().millisecondsSinceEpoch}',
    );
  }
}
