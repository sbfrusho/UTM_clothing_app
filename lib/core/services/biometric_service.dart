import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/app_logger.dart';

/// Biometric **app lock**.
///
/// It never signs anyone in and never stores credentials. Firebase keeps the
/// session; biometrics only unlock an app that already has a signed-in user.
class BiometricService extends GetxService {
  static const _prefKey = 'biometric_lock_enabled';

  final LocalAuthentication _auth = LocalAuthentication();
  final RxBool isLockEnabled = false.obs;

  Future<BiometricService> init() async {
    final prefs = await SharedPreferences.getInstance();
    isLockEnabled.value = prefs.getBool(_prefKey) ?? false;
    return this;
  }

  Future<bool> isAvailable() async {
    try {
      return await _auth.isDeviceSupported() && await _auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      AppLogger.error('Biometric availability check failed', e);
      return false;
    }
  }

  Future<bool> authenticate({String reason = 'Unlock Your Shop'}) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        persistAcrossBackgrounding: true,
      );
    } on LocalAuthException catch (e) {
      AppLogger.error('Biometric authentication failed', e);
      return false;
    } on PlatformException catch (e) {
      AppLogger.error('Biometric authentication failed', e);
      return false;
    }
  }

  /// Turns the lock on (after a successful scan) or off.
  /// Returns whether the new state was applied.
  Future<bool> setLockEnabled(bool enabled) async {
    if (enabled) {
      if (!await isAvailable()) return false;
      if (!await authenticate(reason: 'Confirm to enable app lock')) {
        return false;
      }
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, enabled);
    isLockEnabled.value = enabled;
    return true;
  }
}
