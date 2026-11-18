import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../core/services/auth_service.dart';
import '../routes/app_routes.dart';

/// Guards signed-in routes.
///
/// Signed-out users go to the welcome screen. Unverified users go to the
/// verify-email screen unless [requireVerified] is false (the verify-email
/// route itself).
class AuthMiddleware extends GetMiddleware {
  AuthMiddleware({this.requireVerified = true});

  final bool requireVerified;

  @override
  RouteSettings? redirect(String? route) {
    final auth = Get.find<AuthService>();
    if (!auth.isSignedIn) return const RouteSettings(name: AppRoutes.welcome);
    if (requireVerified && !auth.isEmailVerified) {
      return const RouteSettings(name: AppRoutes.verifyEmail);
    }
    return null;
  }
}
