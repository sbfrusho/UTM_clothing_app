// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAZph4rYcrqZVGIgRWfbbBCDPCV08XkcM4',
    appId: '1:1076136965050:web:a0121967982bdbd2896383',
    messagingSenderId: '1076136965050',
    projectId: 'nabilrayhanshopping',
    authDomain: 'nabilrayhanshopping.firebaseapp.com',
    storageBucket: 'nabilrayhanshopping.appspot.com',
    measurementId: 'G-DD4YGZQ9T0',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyANlPXM6LcGPab6nOYciq83d-cnNaeqKFg',
    appId: '1:1076136965050:android:2baced96cb7b17a1896383',
    messagingSenderId: '1076136965050',
    projectId: 'nabilrayhanshopping',
    storageBucket: 'nabilrayhanshopping.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA3pHXcA0RuYL2jXVHFzzU_2jZfxmv8o80',
    appId: '1:1076136965050:ios:d1d5ee94d5893ffd896383',
    messagingSenderId: '1076136965050',
    projectId: 'nabilrayhanshopping',
    storageBucket: 'nabilrayhanshopping.appspot.com',
    iosBundleId: 'com.example.shoppingApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA3pHXcA0RuYL2jXVHFzzU_2jZfxmv8o80',
    appId: '1:1076136965050:ios:d1d5ee94d5893ffd896383',
    messagingSenderId: '1076136965050',
    projectId: 'nabilrayhanshopping',
    storageBucket: 'nabilrayhanshopping.appspot.com',
    iosBundleId: 'com.example.shoppingApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAZph4rYcrqZVGIgRWfbbBCDPCV08XkcM4',
    appId: '1:1076136965050:web:b1c1941ef90c3c3e896383',
    messagingSenderId: '1076136965050',
    projectId: 'nabilrayhanshopping',
    authDomain: 'nabilrayhanshopping.firebaseapp.com',
    storageBucket: 'nabilrayhanshopping.appspot.com',
    measurementId: 'G-J0TFVE6TSG',
  );

}