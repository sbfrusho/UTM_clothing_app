import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';

import '../core/config/app_config.dart';
import '../core/i18n/app_translations.dart';
import '../core/services/language_service.dart';
import '../core/services/theme_service.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/offline_banner.dart';
import 'bindings/initial_binding.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

class YourShopApp extends StatelessWidget {
  const YourShopApp({super.key});

  /// Large text stays usable without breaking layouts.
  static const maxTextScale = 2.0;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: Get.find<ThemeService>().mode.value,
      translations: AppTranslations(),
      locale: Get.isRegistered<LanguageService>()
          ? Get.find<LanguageService>().locale
          : AppTranslations.english,
      fallbackLocale: AppTranslations.english,
      supportedLocales: AppTranslations.locales,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      initialBinding: InitialBinding(),
      initialRoute: AppRoutes.splash,
      getPages: AppPages.routes,
      defaultTransition: Transition.native,
      builder: (context, child) => MediaQuery.withClampedTextScaling(
        maxScaleFactor: maxTextScale,
        child: Column(
          children: [
            Expanded(child: child ?? const SizedBox.shrink()),
            const OfflineBanner(),
          ],
        ),
      ),
    );
  }
}
