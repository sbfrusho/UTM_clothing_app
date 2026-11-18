import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';

import 'app/bindings/initial_binding.dart';
import 'core/config/app_config.dart';
import 'core/services/biometric_service.dart';
import 'firebase_options.dart';
import 'screens/splash-scree.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (AppConfig.isStripeConfigured) {
    Stripe.publishableKey = AppConfig.stripePublishableKey;
    await Stripe.instance.applySettings();
  }

  await Get.putAsync(() => BiometricService().init(), permanent: true);

  runApp(const YourShopApp());
}

class YourShopApp extends StatelessWidget {
  const YourShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      builder: (context, child) => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: AppConfig.appName,
        initialBinding: InitialBinding(),
        theme: ThemeData(colorSchemeSeed: const Color(0xFF6C0201)),
        home: const SplashScreen(),
      ),
    );
  }
}
