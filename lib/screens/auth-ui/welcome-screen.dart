// ignore_for_file: prefer_final_fields, unused_field

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shopping_app/const/app-colors.dart';
import 'package:shopping_app/controller/sign-in-controller.dart';
import 'package:shopping_app/screens/auth-ui/login-screen.dart';
import 'package:shopping_app/screens/auth-ui/register-screen.dart';
import 'package:shopping_app/screens/user/home-screen.dart';

class WelcomeScreen extends StatefulWidget {
  WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final SignInController signInController = SignInController();
  late final LocalAuthentication localAuth;
  bool _supportState = false;

  @override
  void initState() {
    super.initState();
    localAuth = LocalAuthentication();
    localAuth.isDeviceSupported().then((bool isSupported) => setState(() {
          _supportState = isSupported;
        }));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          color: const Color.fromARGB(255, 248, 246, 242),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  child: Image(
                    image: const AssetImage("assets/utm.jpeg"),
                    height: 80.h,
                    width: 100.w,
                  ),
                ), // Replace with your image path
                const SizedBox(height: 20),
                Container(
                  child: Image(
                    image: const AssetImage("assets/image 1.png"),
                    height: 150.h,
                    width: 2000.w,
                  ),
                ), // Replace with your image path
                const SizedBox(height: 20),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 100.w,
                      height: 50.h,
                      decoration: BoxDecoration(
                        color: AppColor().colorRed,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const LoginScreen()),
                              );
                            },
                            child: Text(
                              "Login",
                              style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: 100.w,
                      height: 50.h,
                      decoration: BoxDecoration(
                        color: AppColor().colorRed,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const RegisterScreen()),
                              );
                            },
                            child: Text(
                              "Register",
                              style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20.h,
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor().colorRed,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                            onPressed: authenticate,
                            child: const Text("Use Biometric Authentication")),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> authenticate() async{
    try{
      bool isAuthenticated = await localAuth.authenticate(
        localizedReason: "Authenticate to login",
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      if(isAuthenticated){
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
        );
      }
    }on PlatformException catch(e){

    }
  }

  Future<void> getBiometricTypes() async {
    List<BiometricType> availableBiometrics =
        await localAuth.getAvailableBiometrics();

      print("available : $availableBiometrics");
      if(!mounted) return;
  }
}
