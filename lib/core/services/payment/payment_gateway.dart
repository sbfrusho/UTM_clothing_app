/// Outcome of a payment attempt. Only [PaymentStatus.success] may lead to
/// an order being placed as paid.
enum PaymentStatus { success, cancelled, failed }

class PaymentResult {
  const PaymentResult._(this.status, {this.message, this.reference});

  const PaymentResult.success({String? reference})
      : this._(PaymentStatus.success, reference: reference);
  const PaymentResult.cancelled()
      : this._(PaymentStatus.cancelled, message: 'Payment cancelled');
  const PaymentResult.failed(String message)
      : this._(PaymentStatus.failed, message: message);

  final PaymentStatus status;
  final String? message;

  /// Gateway transaction / intent id, stored on the order.
  final String? reference;

  bool get isSuccess => status == PaymentStatus.success;
}

/// One implementation per provider (Stripe, demo, and later bKash or
/// SSLCommerz). Checkout depends only on this interface, so adding a gateway
/// does not touch UI code.
abstract interface class PaymentGateway {
  /// Machine id stored on orders, e.g. `stripe`, `demo`, `bkash`.
  String get id;

  /// [amount] is in major units (e.g. 12.50), [currency] is ISO-4217.
  Future<PaymentResult> pay({required double amount, required String currency});
}
