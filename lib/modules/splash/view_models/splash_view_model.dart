import 'package:get/get.dart';

import '../../../core/services/session_service.dart';

/// Shows the brand while [SessionService] decides the first screen.
class SplashViewModel extends GetxController {
  SplashViewModel(this._session);

  final SessionService _session;

  static const _minimumDisplay = Duration(milliseconds: 1200);

  @override
  void onReady() {
    super.onReady();
    _route();
  }

  Future<void> _route() async {
    final minimum = Future<void>.delayed(_minimumDisplay);
    final next = await _session.resolveLaunchRoute();
    await minimum;
    Get.offAllNamed<void>(next);
  }
}
