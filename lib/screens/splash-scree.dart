// ignore: file_names
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shopping_app/const/app-colors.dart';
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
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const HomeScreen()));
    } else {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const WelcomeScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
                valueColor: AlwaysStoppedAnimation<Color>(AppColor().colorRed),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
