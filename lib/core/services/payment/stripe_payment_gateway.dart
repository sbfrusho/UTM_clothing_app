import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

import '../../../data/models/order_model.dart';
import '../../config/app_config.dart';
import '../../utils/app_logger.dart';
import '../../utils/money.dart';
import 'payment_gateway.dart';

/// Stripe PaymentSheet backed by the `createPaymentIntent` Cloud Function
/// (`functions/src/index.ts`). The secret key never ships in the app and the
/// amount is read from the stored order on the server.
///
/// Backend contract:
///   POST {orderId}
///   Authorization: Bearer {Firebase ID token}
///   -> 200 {clientSecret, paymentIntentId, amount (minor units), currency}
///
/// The order is marked paid by the Stripe webhook, not by the app.
class StripePaymentGateway implements PaymentGateway {
  StripePaymentGateway({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

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
            merchantCountryCode: 'MY',
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
    final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
    final response = await _client.post(
      Uri.parse(AppConfig.paymentBackendUrl),
      headers: {
        'Content-Type': 'application/json',
        if (idToken != null) 'Authorization': 'Bearer $idToken',
      },
      body: jsonEncode({'orderId': orderId}),
    );
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      throw _BackendError(
        body['error'] as String? ?? 'Payment could not be started.',
      );
    }
    return (
      clientSecret: body['clientSecret'] as String,
      id: body['paymentIntentId'] as String,
      amount: (body['amount'] as num).toInt(),
    );
  }
}

class _BackendError implements Exception {
  const _BackendError(this.message);
  final String message;
}
