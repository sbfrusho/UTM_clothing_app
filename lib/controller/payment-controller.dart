// // ignore_for_file: prefer_const_constructors

// import 'dart:convert';

// import 'package:flutter_stripe/flutter_stripe.dart';
// import 'package:http/http.dart' as http;

// class PaymentController {
//   Map<String, dynamic>? paymentIntentData;

//   Future<void> makePayment(
//       {required String amount, required String currency}) async {
//     try {
//       paymentIntentData = await createPaymentIntent(amount, currency);
//       if (paymentIntentData != null) {
//         await Stripe.instance.initPaymentSheet(
//             paymentSheetParameters: SetupPaymentSheetParameters(
//           paymentIntentClientSecret: paymentIntentData!['client_secret'],
          
//             ));
//       }
//     } catch (e) {
//       print(e);
//     }
//   }

//   createPaymentIntent(String amount, String currency) async {
//     try {
//       Map<String, dynamic> paymentIntentData = {
//         'amount': amount,
//         'currency': currency,
//         'payment_method_types[]': 'card',
//       };

//       var response = await http.post(
//           Uri.parse('https://api.stripe.com/v1/payment_intents'),
//           body: paymentIntentData,
//           headers: {
//             'Authorization':
//                 'Bearer sk_test_51PGXvy06xtEbkBYxTTHTZWSoJDHDj9d8EH6ru6dqmVBpLCrNUohWeMsPZw31SPN3EbdL1rBRH4JGbGhGKZfZbmeL00HI8Zv3T2',
//             'Content-Type': 'application/x-www-form-urlencoded',
//           });
//       return jsonDecode(response.body);
//     } catch (e) {
//       print(e);
//     }
//   }

//   calculateOrderAmount(String amount) {
//     final total = double.parse(amount) * 100;
//   }
// }


