import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Central logger. Logs only in debug/profile builds so that user data never
/// ends up in release device logs. Crash reporting gets wired in here later.
abstract final class AppLogger {
  static void debug(Object? message) {
    if (kReleaseMode) return;
    developer.log('$message', name: 'YourShop');
  }

  static void error(Object? message, [Object? error, StackTrace? stackTrace]) {
    if (kReleaseMode) return;
    developer.log(
      '$message',
      name: 'YourShop',
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
