//ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables , unused_field, prefer_final_fields
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:your_shop/screens/user/my-cart-screen.dart';
import 'package:your_shop/const/app-colors.dart';
import 'package:your_shop/core/services/biometric_service.dart';
import 'package:your_shop/controller/get-user-data-controller.dart';
import 'package:your_shop/screens/auth-ui/forgot-password-screen.dart';
import 'package:your_shop/screens/auth-ui/welcome-screen.dart';
import 'package:your_shop/screens/user/order-screen.dart';
import 'package:your_shop/screens/user/settings.dart';
import 'package:your_shop/screens/user/user-details-screen.dart';
import 'package:your_shop/screens/user/wish-list.dart';

class DrawerWidget extends StatelessWidget {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  GetUserDataController getUserDataController = Get.put(GetUserDataController());

  User? user = FirebaseAuth.instance.currentUser;

  DrawerWidget({super.key});

  Future<Map<String, dynamic>> fetchUserData() async {
    if (user == null) {
      return {};
    }

    DocumentSnapshot snapshot = await _firestore.collection('users').doc(user!.uid).get();
    return snapshot.data() as Map<String, dynamic>? ?? {};
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: FutureBuilder<Map<String, dynamic>>(
        future: fetchUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('No user data found.'));
          } else {
            Map<String, dynamic> userData = snapshot.data!;
            String? name = userData['name'];

            return ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                ListTile(
                  tileColor: AppColor().colorRed,
                  iconColor: Colors.white,
                  leading: Icon(Icons.arrow_back),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: AppColor().colorRed,
                  ),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image(
                          image: AssetImage('assets/user/user.png'),
                          height: 50.h,
                          width: 50.w,
                        ),
                      ),
                      Text(
                        name ?? 'No Name',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.account_circle),
                  title: Text('Account Information'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserDetailsScreen(), // Pass the user's email
                      ),
                    ); // Close the drawer
                  },
                ),
                ListTile(
                  leading: Icon(Icons.lock),
                  title: Text('Password '),
                  onTap: () {
                    // Add your navigation logic here
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ForgotPasswordScreen()));
                  },
                ),
                ListTile(
                  leading: Icon(Icons.shopping_cart),
                  title: Text('My Cart'),
                  onTap: () {
                    // Add your navigation logic here
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CartScreen())); // Close the drawer
                  },
                ),
                ListTile(
                  leading: Icon(Icons.shopping_bag),
                  title: Text('Order'),
                  onTap: () {
                    // Add your navigation logic here
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => OrderScreen())); // Close the drawer
                  },
                ),
                ListTile(
                  leading: Icon(Icons.favorite),
                  title: Text('Wishlist'),
                  onTap: () {
                    // Add your navigation logic here
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => WishlistScreen()));
                  },
                ),
                ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Settings'),
                  onTap: () {
                    // Add your navigation logic here
                    Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsScreen(email: user!.email.toString())));
                  },
                ),
                Obx(
                  () => SwitchListTile(
                    secondary: Icon(Icons.fingerprint),
                    title: Text('App lock'),
                    subtitle: Text('Require biometrics to open the app'),
                    value: Get.find<BiometricService>().isLockEnabled.value,
                    onChanged: (enabled) async {
                      final applied = await Get.find<BiometricService>()
                          .setLockEnabled(enabled);
                      if (!applied && enabled) {
                        Get.snackbar('App lock',
                            'Biometrics are not available or were not confirmed.');
                      }
                    },
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Log out'),
                  onTap: () async {
                    await auth.signOut();
                    Get.offAll(() => const WelcomeScreen());
                  },
                ),
                // Add more ListTiles for additional items
              ],
            );
          }
        },
      ),
    );
  }
}
