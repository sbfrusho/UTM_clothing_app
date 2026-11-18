import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../core/services/auth_service.dart';
import '../routes/app_routes.dart';

/// Sends signed-out users to the welcome screen for protected routes.
class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final signedIn = Get.find<AuthService>().isSignedIn;
    return signedIn ? null : const RouteSettings(name: AppRoutes.welcome);
  }
}
