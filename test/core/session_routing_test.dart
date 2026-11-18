import 'package:flutter_test/flutter_test.dart';
import 'package:your_shop/app/routes/app_routes.dart';
import 'package:your_shop/core/services/session_service.dart';

void main() {
  String route({
    bool signedIn = true,
    bool verified = true,
    bool lock = false,
    bool launch = false,
  }) => SessionService.destinationFor(
    signedIn: signedIn,
    emailVerified: verified,
    lockEnabled: lock,
    fromLaunch: launch,
  );

  group('SessionService.destinationFor', () {
    test('signed-out users see the welcome screen', () {
      expect(route(signedIn: false), AppRoutes.welcome);
      expect(
        route(signedIn: false, launch: true, lock: true),
        AppRoutes.welcome,
      );
    });

    test('unverified users must verify before anything else', () {
      expect(route(verified: false), AppRoutes.verifyEmail);
      expect(
        route(verified: false, launch: true, lock: true),
        AppRoutes.verifyEmail,
      );
    });

    test('cold start with app lock on goes to the lock screen', () {
      expect(route(launch: true, lock: true), AppRoutes.appLock);
    });

    test('interactive sign-in skips the lock', () {
      expect(route(lock: true), AppRoutes.shell);
    });

    test('verified users without a lock go to the shell', () {
      expect(route(launch: true), AppRoutes.shell);
      expect(route(), AppRoutes.shell);
    });
  });

  test('verify-email and app-lock are not public routes', () {
    expect(SessionService.publicRoutes, isNot(contains(AppRoutes.verifyEmail)));
    expect(SessionService.publicRoutes, isNot(contains(AppRoutes.appLock)));
    expect(SessionService.publicRoutes, contains(AppRoutes.login));
  });
}
