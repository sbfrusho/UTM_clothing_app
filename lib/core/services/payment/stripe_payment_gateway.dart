import 'package:flutter_stripe/flutter_stripe.dart';

import '../../../data/models/order_model.dart';
import '../../config/app_config.dart';
import '../../errors/app_exception.dart';
import '../../utils/app_logger.dart';
import '../../utils/money.dart';
import '../functions_client.dart';
import 'payment_gateway.dart';

/// Stripe PaymentSheet backed by the `createPaymentIntent` Cloud Function
/// (`functions/src/index.ts`). The secret key never ships in the app and the
/// amount is read from the stored order on the server.
///
/// Backend: `createPaymentIntent` POST {orderId}
///   -> {clientSecret, paymentIntentId, amount (minor units), currency}
///
/// The order is marked paid by the Stripe webhook, not by the app.
class StripePaymentGateway implements PaymentGateway {
  StripePaymentGateway({FunctionsClient? functions})
    : _functions = functions ?? FunctionsClient();

  final FunctionsClient _functions;

  @override
  String get id => GatewayId.stripe;

  @override
  Future<PaymentResult> pay({
    required String orderId,
    required double amount,
    required String currency,
  }) async {
    try {
      final intent = await _createPaymentIntent(orderId);
      if (intent.amount != toMinorUnits(amount)) {
        return const PaymentResult.failed(
          'The order total changed. Please review your order.',
        );
      }

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: intent.clientSecret,
          merchantDisplayName: AppConfig.appName,
          googlePay: PaymentSheetGooglePay(
            merchantCountryCode: AppConfig.countryCode,
            currencyCode: currency,
            testEnv: !AppConfig.isProduction,
          ),
        ),
      );
      await Stripe.instance.presentPaymentSheet();
      return PaymentResult.success(reference: intent.id, settledByServer: true);
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) {
        return const PaymentResult.cancelled();
      }
      AppLogger.error('Stripe payment failed', e);
      return PaymentResult.failed(
        e.error.localizedMessage ?? 'Payment failed. Please try again.',
      );
    } on _BackendError catch (e) {
      return PaymentResult.failed(e.message);
    } catch (e, st) {
      AppLogger.error('Stripe payment failed', e, st);
      return const PaymentResult.failed('Payment failed. Please try again.');
    }
  }

  Future<({String clientSecret, String id, int amount})> _createPaymentIntent(
    String orderId,
  ) async {
    try {
      final body = await _functions.call('createPaymentIntent', {
        'orderId': orderId,
      });
      return (
        clientSecret: body['clientSecret'] as String,
        id: body['paymentIntentId'] as String,
        amount: (body['amount'] as num).toInt(),
      );
    } on AppException catch (e) {
      throw _BackendError(e.message);
    }
  }
}

class _BackendError implements Exception {
  const _BackendError(this.message);
  final String message;
}
