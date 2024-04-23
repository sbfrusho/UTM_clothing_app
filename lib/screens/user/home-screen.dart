//ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shopping_app/My%20Cart/my_cart_view.dart';
import 'package:shopping_app/const/app-colors.dart';
import 'package:shopping_app/controller/cart-controller.dart';
import 'package:shopping_app/screens/auth-ui/welcome-screen.dart';
import 'package:shopping_app/widgets/banner-widget.dart';
import 'package:shopping_app/widgets/custom-drawer-widget.dart';

import '../../widgets/Categories.dart';
import '../../widgets/slider-image.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CartController cartController = Get.find();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          title: const Text(
            "Home",
            style: TextStyle(color: Colors.white),
          ),
          // leading: const Icon(
          //   Icons.menu,
          //   color: Colors.white,
          // ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () async {
                // Handle logout
                await _auth.signOut();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const WelcomeScreen()));
              },
            ),
          ],

          backgroundColor: AppColor().colorRed,
        ),
        drawer: DrawerWidget(),


        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: const Color.fromARGB(255, 248, 246, 242),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(30),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: const Icon(Icons.mic),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  // child: SliderImage(imageUrl: "assets/Tshirt/utm_tshirt_1.jpg",),
                  child: Column(
                    children: [
                      BannerWidget(),
                    ],
                  ),
                ),
                
                Categories(),

                SizedBox(
                  height: 20.h,
                ),

                Padding(
                  padding: const EdgeInsets.all(10),
                  // child: SliderImage(imageUrl: "assets/Tshirt/utm_tshirt_1.jpg",),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 30, bottom: 20),
                        child: Text("Recommended for you"),
                      ),
                      BannerWidget(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 0, // Set the initial index of the selected item
          selectedItemColor: Colors.red, // Set the color of the selected item
          unselectedItemColor:
              Colors.grey, // Set the color of the unselected items
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
            // Handle the tap event for each item
            switch (index) {
              case 0:
                // Handle the Home item tap
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomeScreen(),
                  ),
                );
                break;
              case 1:
                // Handle the Wishlist item tap
                break;
              case 2:
                // Handle the Categories item tap
                break;
              case 3:
                // Handle the Cart item tap
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CartScreen(
                      cartItems: [],
                    ),
                  ),
                );
                break;
              case 4:
                // Handle the Profile item tap
                break;
            }
          },
          
        ),
      ),
    );
  }
}

