import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shopping_app/const/app-colors.dart';

import '../../const/sizes.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "My Cart",
            style: TextStyle(color: Colors.white),
          ),
          leading: const Icon(
            Icons.menu,
            color: Colors.white,
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.search,
                color: Colors.white,
              ),
              onPressed: () {},
            ),
          ],
          backgroundColor: AppColor().colorRed,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(Sizes.defaultSpace),
            child: Container(
              color: const Color.fromARGB(255, 248, 246, 242),
              child: ListView.separated(
                  itemBuilder: (_, index) {
                    const Column(
                      children: [
                        Row(
                          children: [
                            Image(
                              image: AssetImage('assets/images/1.jpg'),
                              height: 60,
                              width: 60,
                            ),
                          ],
                        )
                      ],
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(
                        height: Sizes.spaceBtwISections,
                      ),
                  itemCount: 4),
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
                break;
              case 1:
                // Handle the Wishlist item tap
                break;
              case 2:
                // Handle the Categories item tap
                break;
              case 3:
                // Handle the Cart item tap
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
