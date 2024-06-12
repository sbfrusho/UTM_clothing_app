//ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables , unused_field, prefer_final_fields
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:shopping_app/My%20Cart/my_cart_view.dart';
import 'package:shopping_app/const/app-colors.dart';
import 'package:shopping_app/controller/get-user-data-controller.dart';
import 'package:shopping_app/screens/auth-ui/forgot-password-screen.dart';
import 'package:shopping_app/screens/auth-ui/login-screen.dart';
import 'package:shopping_app/screens/user/order-screen.dart';
import 'package:shopping_app/screens/user/user-details-screen.dart';
import 'package:shopping_app/screens/user/wish-list.dart';

class DrawerWidget extends StatelessWidget {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  GetUserDataController getUserDataController =
      Get.put(GetUserDataController());

  User? user = FirebaseAuth.instance.currentUser;

  var userData;

  Future<void> getUserData() async {
    userData = await getUserDataController.getUserData(user!.uid);
  }


  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
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
                  "Nabil",
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
              ; // Close the drawer
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () {
              // Add your navigation logic here
              // Navigator.pop(context); // Close the drawer
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Log out'),
            onTap: () {
              auth.signOut();
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => LoginScreen()));
            },
          ),

          // Add more ListTiles for additional items
        ],
      ),
    );
  }
}
