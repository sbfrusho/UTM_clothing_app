import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shopping_app/const/app-colors.dart';
import 'package:shopping_app/controller/sign-in-controller.dart';
import 'package:shopping_app/screens/auth-ui/login-screen.dart';
import 'package:shopping_app/screens/auth-ui/register-screen.dart';
import 'package:shopping_app/screens/user/home-screen.dart';

class WelcomeScreen extends StatefulWidget {
  final User? user;
  final String password;

  WelcomeScreen({Key? key, required this.user, required this.password})
      : super(key: key);

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
                                  builder: (context) => const LoginScreen(),
                                ),
                              );
                            },
                            child: Text(
                              "Login",
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
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
                                      const RegisterScreen(),
                                ),
                              );
                            },
                            child: Text(
                              "Register",
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
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
                          onPressed: () {
                            authenticate(widget.user);
                          },
                          child: const Text("Use Biometric Authentication" , style: TextStyle(color: Colors.white)),
                        ),
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

  Future<void> authenticate(User? user) async {
    try {
      bool isAuthenticated = await localAuth.authenticate(
        localizedReason: "Authenticate to login",
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      if (isAuthenticated) {
        if (user != null) {
          // Call signInWithBiometrics with user and password
          signInWithBiometrics(user, widget.password);
        } else {
          showToast(context, "No user found. Please log in manually first.");
        }
      }
    } on PlatformException catch (e) {
      showToast(context, "Authentication failed: ${e.message}");
    }
  }

  Future<void> signInWithBiometrics(User user, String password) async {
    try {
      // You can implement your biometric authentication logic here
      // For simplicity, assuming biometric authentication is successful
      // and then signing in with Firebase using the provided user
      print("user email : ${user.email.toString()} , password : $password" );
      await signInController.signInMethod(user.email.toString(), password);

      // Navigate to home screen upon successful sign-in
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
    } catch (e) {
      showToast(context, "Failed to sign in: ${e.toString()}");
    }
  }

  void showToast(BuildContext context, String message) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(
          label: 'OK',
          onPressed: scaffold.hideCurrentSnackBar,
        ),
      ),
    );
  }
}
