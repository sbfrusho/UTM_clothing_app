import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

import '../../config/app_config.dart';
import '../../utils/app_logger.dart';
import 'payment_gateway.dart';

/// Stripe PaymentSheet. The PaymentIntent is created **server-side** by
/// [AppConfig.paymentBackendUrl]; the secret key never ships in the app.
///
/// Backend contract:
///   POST {amount: int (minor units), currency: string}
///   Authorization: Bearer <Firebase ID token>
///   -> 200 {clientSecret: string, paymentIntentId: string}
class StripePaymentGateway implements PaymentGateway {
  StripePaymentGateway({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  @override
  String get id => 'stripe';

  @override
  Future<PaymentResult> pay({
    required double amount,
    required String currency,
  }) async {
    try {
      final intent = await _createPaymentIntent(amount, currency);

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
      return PaymentResult.success(reference: intent.id);
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) {
        return const PaymentResult.cancelled();
      }
      AppLogger.error('Stripe payment failed', e);
      return PaymentResult.failed(
        e.error.localizedMessage ?? 'Payment failed. Please try again.',
      );
    } catch (e, st) {
      AppLogger.error('Stripe payment failed', e, st);
      return const PaymentResult.failed('Payment failed. Please try again.');
    }
  }

  Future<({String clientSecret, String? id})> _createPaymentIntent(
    double amount,
    String currency,
  ) async {
    final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
    final response = await _client.post(
      Uri.parse(AppConfig.paymentBackendUrl),
      headers: {
        'Content-Type': 'application/json',
        if (idToken != null) 'Authorization': 'Bearer $idToken',
      },
      body: jsonEncode({
        'amount': (amount * 100).round(),
        'currency': currency.toLowerCase(),
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Payment backend returned ${response.statusCode}');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return (
      clientSecret: body['clientSecret'] as String,
      id: body['paymentIntentId'] as String?,
    );
  }
}
