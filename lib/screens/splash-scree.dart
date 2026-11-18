// ignore: file_names , unused_import, unused_field
// ignore_for_file: library_private_types_in_public_api, avoid_unnecessary_containers, use_build_context_synchronously

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:your_shop/const/app-colors.dart';
import 'package:your_shop/controller/get-user-data-controller.dart';
import 'package:your_shop/core/services/biometric_service.dart';
import 'package:your_shop/core/utils/app_logger.dart';
import 'package:your_shop/screens/auth-ui/app-lock-screen.dart';
import 'package:your_shop/screens/auth-ui/welcome-screen.dart';
import 'package:your_shop/screens/user/home-screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 1500), _route);
  }

  Future<void> _route() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || !user.emailVerified) {
      Get.offAll(() => const WelcomeScreen());
      return;
    }

    try {
      final userData =
          await Get.put(GetUserDataController()).getUserData(user.uid);
      if (userData.isNotEmpty && userData.first['isAdmin'] == true) {
        // Admins use the separate admin app.
        await FirebaseAuth.instance.signOut();
        Get.offAll(() => const WelcomeScreen());
        return;
      }
    } catch (e, st) {
      AppLogger.error('Could not load user profile on launch', e, st);
    }

    if (Get.find<BiometricService>().isLockEnabled.value) {
      Get.offAll(() => const AppLockScreen());
    } else {
      Get.offAll(() => const HomeScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          // Customize your splash screen UI here
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Add your logo in the image folder and provide the path here
                Container(
                  child: Image(
                    image: const AssetImage("assets/For Design Picture/fp.png"),
                    height: 600.h,
                    width: 600.w,
                  ),
                ),
                CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColor().colorRed),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
