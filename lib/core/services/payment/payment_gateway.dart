/// Outcome of a payment attempt. Only [PaymentStatus.success] may lead to
/// an order being treated as paid.
enum PaymentStatus { success, cancelled, failed }

class PaymentResult {
  const PaymentResult._(
    this.status, {
    this.message,
    this.reference,
    this.settledByServer = false,
  });

  const PaymentResult.success({String? reference, bool settledByServer = false})
    : this._(
        PaymentStatus.success,
        reference: reference,
        settledByServer: settledByServer,
      );
  const PaymentResult.cancelled()
    : this._(PaymentStatus.cancelled, message: 'Payment cancelled');
  const PaymentResult.failed(String message)
    : this._(PaymentStatus.failed, message: message);

  final PaymentStatus status;
  final String? message;

  /// Gateway transaction / intent id.
  final String? reference;

  /// True when the gateway's server marks the order paid (Stripe webhook);
  /// false when the app must record it (test payments only).
  final bool settledByServer;

  bool get isSuccess => status == PaymentStatus.success;
}

/// One implementation per provider (Stripe, demo, later bKash or
/// SSLCommerz). Checkout depends only on this interface.
abstract interface class PaymentGateway {
  /// Stored on orders as `paymentGateway`, e.g. `stripe`, `demo`.
  String get id;

  /// Pays for the stored order [orderId]. [amount] (major units) is shown to
  /// the customer; server-backed gateways charge the order's stored total
  /// and refuse if the two differ.
  Future<PaymentResult> pay({
    required String orderId,
    required double amount,
    required String currency,
  });
}
