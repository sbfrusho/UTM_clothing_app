// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:shopping_app/const/app-colors.dart';
// import 'package:shopping_app/screens/auth-ui/login-screen.dart';
// import 'package:shopping_app/widgets/button.dart';

// class RegisterScreen extends StatefulWidget {
//   const RegisterScreen({super.key});

//   @override
//   State<RegisterScreen> createState() => _RegisterScreenState();
// }

// class _RegisterScreenState extends State<RegisterScreen> {

//   List<String> gender = ['male' , 'female' , 'other']; // Option 2
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         appBar: AppBar(
//           leading: IconButton(
//             icon: Icon(Icons.arrow_back, color: Colors.white),
//             onPressed: () => Navigator.of(context).pop(),
//           ),

//           centerTitle: true,
//           backgroundColor: AppColor().colorRed,
//           title: Text(
//             "Sign Up",
//             style: TextStyle(color: Colors.white),
//           ),
//         ),
//         body: SingleChildScrollView(
//           child: Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.only(top: 50),
//                 child: Image(
//                   image: AssetImage("assets/utm.jpeg"),
//                   height: 100.h,
//                   width: 150.h,
//                 ),
//               ),
//               Padding(
//                 padding: EdgeInsets.all(10),
//                 child: TextField(
//                   decoration: InputDecoration(
//                       border: OutlineInputBorder(),
//                       labelText: 'Full Name',
//                       hintText: 'Ex. John Doe'),
//                 ),
//               ),
//               SizedBox(
//                 height: 20,
//               ),
//               Padding(
//                 padding: EdgeInsets.all(10),
//                 child: TextField(
//                   decoration: InputDecoration(
//                       border: OutlineInputBorder(),
//                       labelText: 'Email',
//                       hintText: 'Ex. abc@gmail.com'),
//                 ),
//               ),
//               SizedBox(
//                 height: 20,
//               ),
//               Padding(
//                 padding: EdgeInsets.all(10),
//                 child: TextField(
//                   decoration: InputDecoration(
//                       border: OutlineInputBorder(),
//                       labelText: 'Phone Number',
//                       hintText: 'Ex. 1234567890'),
//                 ),
//               ),
//               SizedBox(
//                 height: 20,
//               ),
//               Padding(
//                 padding: EdgeInsets.all(10),
//                 child: TextField(
//                   decoration: InputDecoration(
//                       border: OutlineInputBorder(),
//                       labelText: 'Date of Birth',
//                       hintText: 'dd/mm/yyyy'),
//                 ),
//               ),
//               SizedBox(
//                 height: 20,
//               ),
//               Padding(
//                 padding: EdgeInsets.all(10),
//                 child: TextField(
//                   decoration: InputDecoration(
//                       border: OutlineInputBorder(),
//                       labelText: 'Password',
//                       hintText: 'hint: 0x12abc..'),
//                 ),
//               ),
//               SizedBox(
//                 height: 20,
//               ),
//               Padding(
//                 padding: EdgeInsets.all(10),
//                 child: TextField(
//                   readOnly: true,
//                   decoration: InputDecoration(
//                     hintText: 'Choose your gender',
//                     border: OutlineInputBorder(),
//                     prefixIcon: DropdownButton<String>(
//                       items: gender.map((String value) {
//                         return DropdownMenuItem<String>(
//                           value: value,
//                           child: new Text(value),
//                           onTap: (){
//                             setState(() {
//                               value = value;
//                             });
//                           },
//                         );
//                       }).toList(), onChanged: (String? value) {  },
//                     ),
//                   ),
//                 ),
//               ),

//               Container(
//               width: 100.w,
//               height: 50.h,
//               decoration: BoxDecoration(
//                 color: AppColor().colorRed,
//                 borderRadius: BorderRadius.circular(50),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   GestureDetector(
//                     onTap: () {
//                     },
//                     child: Text(
//                       "Continue",
//                       style: TextStyle(
//                           fontSize: 12.sp,
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shopping_app/const/app-colors.dart';
import 'package:shopping_app/controller/sign-up-controller.dart';
import 'package:shopping_app/screens/auth-ui/login-screen.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
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
            color: const Color.fromARGB(255, 248, 246, 242),
            child: Column(
              children: [
                Image(
                  image: const AssetImage(
                    "assets/utm.jpeg",
                  ),
                  width: 150.w,
                  height: 200.h,
                ),
                Text(
                  'Register Form',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColor().colorRed,
                  ),
                ),
                const SizedBox(height: 20),
                const RegisterForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

//make a register form
class RegisterForm extends StatelessWidget {
  const RegisterForm({super.key});

  @override
  Widget build(BuildContext context) {
    final SignUpController registerController = Get.put(SignUpController());
    TextEditingController nameController = TextEditingController();
    TextEditingController emailController = TextEditingController();
    TextEditingController phoneController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    User? user = FirebaseAuth.instance.currentUser;

    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        children: [
          TextFormField(
            controller: nameController,
            decoration: InputDecoration(
              icon: const Icon(Icons.man),
              labelText: 'Name',
              hintText: 'Enter your name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: emailController,
            decoration: InputDecoration(
              icon: const Icon(Icons.email),
              labelText: 'Email',
              hintText: 'Enter your email',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: phoneController,
            decoration: InputDecoration(
              icon: const Icon(Icons.phone),
              labelText: 'Phone',
              hintText: 'Enter your Phone Number',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Obx(
              () => TextFormField(
                controller: passwordController,
                obscureText: registerController.isPasswordVisible.value,
                decoration: InputDecoration(
                  icon: const Icon(Icons.lock),
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  suffixIcon: GestureDetector(
                    onTap: () {
                      registerController.isPasswordVisible.toggle();
                    },
                    child: Icon(registerController.isPasswordVisible.value
                        ? Icons.visibility_off
                        : Icons.visibility),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
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
                  onTap: () async {
                    String name = nameController.text.trim();
                    String email = emailController.text.trim();
                    String phone = phoneController.text.trim();
                    String password = passwordController.text.trim();
                    String deviceToken = '';

                    CollectionReference users =
                        FirebaseFirestore.instance.collection('users');

                    // Check if any field is empty
                    if (name.isEmpty ||
                        email.isEmpty ||
                        phone.isEmpty ||
                        password.isEmpty) {
                      showToast(context, 'All fields are required');
                      return;
                    }

                    try {
                      // Call the registration method

                      await registerController.signUpMethod(
                        name,
                        email,
                        phone,
                        password,
                        deviceToken,
                      );

                      // await registerController.signUpMethod(
                      //   name,
                      //   email,
                      //   phone,
                      //   password,
                      //   deviceToken,
                      // );

                      // saveDataToDB() async{
                      //   Conn
                      // }

                      showToast(context,
                          "Registration successful. Verify your email to login.");

                      // Save the user data to Firestore if email verification is successful

                      

                      // Clear the text fields
                      nameController.clear();
                      emailController.clear();
                      phoneController.clear();
                      passwordController.clear();

                      // Sign out the current user (if any)
                      await FirebaseAuth.instance.signOut();

                      // Navigate to welcome screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    } catch (e) {
                      // Handle registration errors
                      print("Registration failed: $e");
                      showToast(context,
                          "Registration failed. Please try again later.");
                    }
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
        ],
      ),
    );
  }
}

//create a Toast Message for the user
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
