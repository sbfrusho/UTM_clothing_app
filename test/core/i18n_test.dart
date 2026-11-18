import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:your_shop/core/i18n/app_translations.dart';
import 'package:your_shop/core/i18n/ms_translations.dart';
import 'package:your_shop/core/services/connectivity_service.dart';
import 'package:your_shop/core/utils/validators.dart';
import 'package:your_shop/data/models/user_model.dart';

void main() {
  group('AppTranslations', () {
    test('resolves saved choice, then supported device language, then en', () {
      expect(
        AppTranslations.resolve('ms', const Locale('en')).languageCode,
        'ms',
      );
      expect(
        AppTranslations.resolve(null, const Locale('ms')).languageCode,
        'ms',
      );
      expect(
        AppTranslations.resolve(null, const Locale('fr')).languageCode,
        'en',
      );
      expect(AppTranslations.resolve('xx', null).languageCode, 'en');
      expect(AppTranslations.isSupported('ms'), isTrue);
      expect(AppTranslations.isSupported(null), isFalse);
    });

    test('Malay strings keep every @placeholder of their key', () {
      final placeholder = RegExp(r'@\w+');
      msTranslations.forEach((key, value) {
        final wanted = placeholder.allMatches(key).map((m) => m[0]).toSet();
        final got = placeholder.allMatches(value).map((m) => m[0]).toSet();
        expect(got, wanted, reason: key);
        expect(value.trim(), isNotEmpty, reason: key);
      });
    });

    testWidgets('switching locale translates shared strings and validators', (
      tester,
    ) async {
      await tester.pumpWidget(
        GetMaterialApp(
          translations: AppTranslations(),
          locale: AppTranslations.english,
          fallbackLocale: AppTranslations.english,
          home: const SizedBox(),
        ),
      );
      expect('Log out'.tr, 'Log out');
      expect(Validators.required('', field: 'Name'), 'Name is required');

      // updateLocale also reassembles the app, which never settles in tests.
      Get.locale = AppTranslations.malay;
      expect('Log out'.tr, 'Log keluar');
      expect(Validators.required('', field: 'Name'), 'Nama diperlukan');
      expect('Not in the dictionary'.tr, 'Not in the dictionary');
      Get.locale = AppTranslations.english;
    });
  });

  test('ConnectivityService treats "none" only as offline', () {
    expect(ConnectivityService.hasNetwork([ConnectivityResult.none]), isFalse);
    expect(ConnectivityService.hasNetwork(const []), isFalse);
    expect(
      ConnectivityService.hasNetwork([
        ConnectivityResult.none,
        ConnectivityResult.wifi,
      ]),
      isTrue,
    );
  });

  test('UserModel keeps the profile photo, outside customer-edited fields', () {
    const user = UserModel(uid: 'u', email: 'e@x.com', photoUrl: 'https://p');
    expect(UserModel.fromMap(user.toMap()).photoUrl, 'https://p');
    expect(user.copyWith(name: 'A').photoUrl, 'https://p');
    expect(user.toProfileUpdate().containsKey('photoUrl'), isFalse);
  });
}
