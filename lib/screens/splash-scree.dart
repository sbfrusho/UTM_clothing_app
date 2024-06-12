// ignore: file_names , unused_import, unused_field
// ignore_for_file: library_private_types_in_public_api, avoid_unnecessary_containers, use_build_context_synchronously

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shopping_app/const/app-colors.dart';
import 'package:shopping_app/controller/get-user-data-controller.dart';
import 'package:shopping_app/screens/admin-panel/admin-screen.dart';
import 'package:shopping_app/screens/auth-ui/welcome-screen.dart';
import 'package:shopping_app/screens/user/home-screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      keepUserLoggedIn(context);
    });
  }

  Future<void> keepUserLoggedIn(BuildContext context) async {
    if (user != null) {

      final GetUserDataController getUserDataController =
          Get.put(GetUserDataController());
      var userData = await getUserDataController.getUserData(user!.uid);


      if (userData[0]['isAdmin'] == true) {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const AdminScreen()));
      } else {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const HomeScreen()));
      }
    } else {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) =>  WelcomeScreen()));
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
                    image: const AssetImage("assets/logo1.png"),
                    height: 200.h,
                    width: 200.w,
                  ),
                ),
                const SizedBox(height: 20),
                // Add your app name here
                Text(
                  'UTM E-COMMERCE APP\nEnhance Your Shopping Experience',
                  style: TextStyle(
                    color: AppColor().colorRed,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
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
