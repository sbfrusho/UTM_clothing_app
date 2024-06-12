// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors_in_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shopping_app/const/app-colors.dart';
import 'package:shopping_app/screens/user/order-screen.dart';
import 'package:shopping_app/screens/user/shipping-address.dart';


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
    );
  }
}