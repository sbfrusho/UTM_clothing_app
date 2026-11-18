import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:your_shop/core/utils/app_logger.dart';

Future<String?> getCustomerDeviceToken() async {
  try {
    String? token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      AppLogger.debug("Device token: $token");
      return token;
    } else {
      AppLogger.debug("Error: Failed to get device token");
      return null;
    }
  } catch (e) {
    AppLogger.debug("Error fetching device token: $e");
    return null;
  }
}
