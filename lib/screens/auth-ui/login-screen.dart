import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shopping_app/const/app-colors.dart';

import '../../controller/sign-in-controller.dart';
import '../user/home-screen.dart';
import 'forgot-password-screen.dart';
import 'register-screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    // add a media query to get the screen size
    final mediaQuery = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColor().colorRed,
          //Add a back button to left of the app bar
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Image(
                    image: AssetImage(
                      "assets/utm.jpeg",
                    ),
                    width: 200,
                    height: 200,
                  ),
                  LoginForm(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Don\'t have an account?'),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const RegisterScreen()));
                        },
                        child: const Text(
                          "Click Here",
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LoginForm extends StatelessWidget {
  final SignInController signInController = Get.put(SignInController());
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextFormField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Obx(
              () => TextFormField(
                controller: passwordController,
                obscureText: signInController.isPasswordVisible.value,
                decoration: InputDecoration(
                  labelText: 'Password',
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  suffixIcon: GestureDetector(
                    onTap: () {
                      signInController.isPasswordVisible.toggle();
                    },
                    child: signInController.isPasswordVisible.value
                        ? const Icon(Icons.visibility_off)
                        : const Icon(Icons.visibility),
                  ),
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const ForgotPasswordScreen()));
                },
                child: Text(
                  "Forgot Password",
                  style: TextStyle(color: AppColor().colorRed),
                ),
              ),
            ],
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
                  onTap: () async {
                    String email = emailController.text.trim();
                    String password = passwordController.text.trim();

                    if (email.isEmpty || password.isEmpty) {
                      showToast(context, "All fields are required");
                    } else {
                      UserCredential? userCredential =
                          await signInController.signInMethod(email, password);

                      String? whoLoggedIn = "";

                      // print("Hello Wrold ------ >>>>>>>>");
                      // print(userData);
                      // print("End ---------- ......>>>>>>>>>>>>");

                      // ignore: unnecessary_null_comparison
                      if (userCredential != null) {
                        if (userCredential.user!.emailVerified) {
                          showToast(context, "Login $whoLoggedIn Successful");

                          Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => const HomeScreen()));

                          return; // Return here to prevent showing unnecessary toasts or snackbar
                        } else {
                          showToast(
                              context, "Please verify your email before login");
                        }
                      } else {
                        showToast(context, "Login failed. Please try again.");
                      }
                    }
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
        ],
      ),
    );
  }
}

//create a toast message for the login
void showToast(BuildContext context, String message) {
  final scaffold = ScaffoldMessenger.of(context);
  scaffold.showSnackBar(
    SnackBar(
      content: Text(message),
      action: SnackBarAction(
        label: 'UNDO',
        onPressed: scaffold.hideCurrentSnackBar,
      ),
    ),
  );
}
