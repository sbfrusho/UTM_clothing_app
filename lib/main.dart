import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';

import 'app/app.dart';
import 'core/config/app_config.dart';
import 'core/services/biometric_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/theme_service.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (AppConfig.isStripeConfigured) {
    Stripe.publishableKey = AppConfig.stripePublishableKey;
    await Stripe.instance.applySettings();
  }

  // Needed synchronously at startup (theme, splash route decision).
  await Get.putAsync(() => ThemeService().init(), permanent: true);
  await Get.putAsync(() => BiometricService().init(), permanent: true);
  await Get.putAsync(() => NotificationService().init(), permanent: true);

  runApp(const YourShopApp());
}
