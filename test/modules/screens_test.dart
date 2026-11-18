import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';
import 'package:your_shop/app/routes/app_routes.dart';
import 'package:your_shop/core/errors/app_exception.dart';
import 'package:your_shop/core/services/auth_service.dart';
import 'package:your_shop/core/services/session_service.dart';
import 'package:your_shop/core/theme/app_theme.dart';
import 'package:your_shop/data/repositories/auth_repository.dart';
import 'package:your_shop/modules/auth/view_models/login_view_model.dart';
import 'package:your_shop/modules/auth/view_models/social_sign_in_view_model.dart';
import 'package:your_shop/modules/auth/views/login_view.dart';
import 'package:your_shop/modules/profile/view_models/delete_account_view_model.dart';
import 'package:your_shop/modules/profile/views/delete_account_view.dart';

class _AuthRepo extends Mock implements AuthRepository {}

class _Session extends Mock implements SessionService {}

class _Auth extends Mock implements AuthService {}

Widget _app(Widget home) => GetMaterialApp(
  theme: AppTheme.light,
  getPages: [
    GetPage(name: '/', page: () => home),
    GetPage(
      name: AppRoutes.shell,
      page: () => const Scaffold(body: Text('shell')),
    ),
  ],
);

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  late _AuthRepo repo;
  late _Session session;

  setUp(() {
    repo = _AuthRepo();
    session = _Session();
  });
  tearDown(Get.reset);

  group('LoginView', () {
    setUp(() {
      Get.put(LoginViewModel(repo, session), permanent: true);
      Get.put(SocialSignInViewModel(repo, session), permanent: true);
    });

    testWidgets('validates before calling the server', (tester) async {
      await tester.pumpWidget(_app(const LoginView()));
      await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
      await tester.pump();

      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
      verifyNever(
        () => repo.signIn(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      );
    });

    testWidgets('signs in and goes where the session decides', (tester) async {
      final User user = MockUser(uid: 'u1', email: 'a@x.com');
      when(
        () => repo.signIn(email: 'a@x.com', password: 'secret12'),
      ).thenAnswer((_) async => user);
      when(
        () => session.completeSignIn(user),
      ).thenAnswer((_) async => AppRoutes.shell);

      await tester.pumpWidget(_app(const LoginView()));
      await tester.enterText(find.byType(TextFormField).at(0), ' a@x.com ');
      await tester.enterText(find.byType(TextFormField).at(1), 'secret12');
      await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
      await _settle(tester);

      expect(find.text('shell'), findsOneWidget);
    });

    testWidgets('shows the error and stays on the screen', (tester) async {
      when(
        () => repo.signIn(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(const AppException('Incorrect email or password.'));

      await tester.pumpWidget(_app(const LoginView()));
      await tester.enterText(find.byType(TextFormField).at(0), 'a@x.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'wrong123');
      await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
      await _settle(tester);

      expect(find.text('Incorrect email or password.'), findsOneWidget);
      expect(find.byType(LoginView), findsOneWidget);
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
    });
  });

  group('DeleteAccountView', () {
    late _Auth auth;

    setUp(() {
      auth = _Auth();
      when(() => auth.email).thenReturn('a@x.com');
    });

    FilledButton button(WidgetTester tester) => tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Delete my account'),
    );

    testWidgets('needs the confirmation and the password', (tester) async {
      when(() => auth.hasPassword).thenReturn(true);
      when(
        () => repo.reauthenticate(password: 'secret12'),
      ).thenAnswer((_) async => true);
      when(() => repo.deleteAccount()).thenAnswer((_) async {});
      Get.put(DeleteAccountViewModel(auth, repo), permanent: true);

      await tester.pumpWidget(_app(const DeleteAccountView()));
      expect(find.textContaining('a@x.com'), findsOneWidget);
      expect(button(tester).onPressed, isNull);

      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      expect(button(tester).onPressed, isNotNull);

      await tester.tap(find.text('Delete my account'));
      await tester.pump();
      expect(find.text('Enter your password to continue.'), findsOneWidget);
      verifyNever(() => repo.deleteAccount());

      await tester.enterText(find.byType(TextFormField), 'secret12');
      await tester.tap(find.text('Delete my account'));
      await _settle(tester);
      verifyInOrder([
        () => repo.reauthenticate(password: 'secret12'),
        () => repo.deleteAccount(),
      ]);
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
    });

    testWidgets('Google accounts confirm with Google; cancelling deletes '
        'nothing', (tester) async {
      when(() => auth.hasPassword).thenReturn(false);
      when(() => repo.reauthenticate()).thenAnswer((_) async => false);
      Get.put(DeleteAccountViewModel(auth, repo), permanent: true);

      await tester.pumpWidget(_app(const DeleteAccountView()));
      expect(find.byType(TextFormField), findsNothing);
      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      await tester.tap(find.text('Delete my account'));
      await _settle(tester);

      verify(() => repo.reauthenticate()).called(1);
      verifyNever(() => repo.deleteAccount());
    });
  });
}
