// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors_in_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shopping_app/My%20Cart/my_cart_view.dart';
import 'package:shopping_app/const/app-colors.dart';
import 'package:shopping_app/screens/user/all-category.dart';
import 'package:shopping_app/screens/user/home-screen.dart';
import 'package:shopping_app/screens/user/order-screen.dart';
import 'package:shopping_app/screens/user/shipping-address.dart';
import 'package:shopping_app/screens/user/wish-list.dart';


class UserDetailsScreen extends StatelessWidget {

  UserDetailsScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor().colorRed,
        title: Text('Your Details',style: TextStyle(color: Colors.white),),
      ),
      body: Column(
        children: [
          // Lower Portion: Options
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  title: Text('My Orders', style: TextStyle(color: AppColor().colorRed)),
                  trailing: Icon(Icons.arrow_forward_ios, color: AppColor().colorRed),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => OrderScreen()));
                  },
                ),
                Divider(height: 1, color: AppColor().colorRed),
                ListTile(
                  title: Text('Shipping Address', style: TextStyle(color: AppColor().colorRed)),
                  trailing: Icon(Icons.arrow_forward_ios, color: AppColor().colorRed),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => AddAddressScreen()));
                  },
                ),
                Divider(height: 1, color: AppColor().colorRed),
                ListTile(
                  title: Text('Settings', style: TextStyle(color: AppColor().colorRed)),
                  trailing: Icon(Icons.arrow_forward_ios, color: AppColor().colorRed),
                  onTap: () {
                    // Get.to(SettingsScreen());
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: 0,
          selectedItemColor: Colors.red,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'Wishlist',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.category),
              label: 'Categories',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: 'Cart',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
          onTap: (index) {
            switch (index) {
              case 0:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                );
                break;
              case 1:
                // Handle the Wishlist item tap
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => WishlistScreen()));
                break;
              case 2:
                // Handle the Categories item tap
                Get.offAll(AllCategoriesScreen());
                break;
              case 3:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CartScreen()),
                );
                break;
              case 4:
                // Handle the Profile item tap
                break;
            }
          },
        ),
    );
  }
}