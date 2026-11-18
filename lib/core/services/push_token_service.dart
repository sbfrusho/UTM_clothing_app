import 'package:firebase_messaging/firebase_messaging.dart';

import '../utils/app_logger.dart';

/// FCM device token used by the admin app to notify customers.
/// Full notification handling arrives in Sprint 8.
abstract final class PushTokenService {
  static Future<String?> getToken() async {
    try {
      // The admin app targets the classic FCM registration token. Migrate
      // to register()/onRegistered together with the admin app (Sprint 8).
      // ignore: deprecated_member_use
      return await FirebaseMessaging.instance.getToken();
    } catch (e, st) {
      AppLogger.error('Could not get FCM token', e, st);
      return null;
    }
  }
}
