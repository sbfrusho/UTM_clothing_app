// ignore: file_names
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shopping_app/const/app-colors.dart';

class TshirtScreen extends StatefulWidget {
  const TshirtScreen({super.key});

  @override
  State<TshirtScreen> createState() => _TshirtScreenState();
}

class _TshirtScreenState extends State<TshirtScreen> {
  List<String> imagesURL = [
    'assets/Tshirt/tshirt1.jpeg',
    "assets/Tshirt/tshirt2.jpeg",
    "assets/Tshirt/tshirt2.jpg",
    "assets/Tshirt/tshirt3.jpeg",
    "assets/Tshirt/image.png",
    "assets/Tshirt/tshirt2.jpeg",
    "assets/Tshirt/utm_tshirt_1.jpg",
    "assets/Corporate/tshirt.jpg"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Home",
          style: TextStyle(color: Colors.white),
        ),
        leading: const Icon(
          Icons.menu,
          color: Colors.white,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search , color: Colors.white,),
            onPressed: () {
            },
          ),
        ],
        backgroundColor: AppColor().colorRed,
      ),
      body: Container(child: content()),
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
    );
  }

  Widget content() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, mainAxisSpacing: 20, crossAxisSpacing: 20),
          itemCount: imagesURL.length,
      itemBuilder: (content, index) {
        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(imagesURL[index]),
              fit: BoxFit.fill,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                color: Colors.black.withOpacity(0.5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Text(
                      "Premium Cotton \nt-shirt\nPrice : 55 RM",
                      style: TextStyle(color: Colors.white),
                    ),
                    IconButton(
                      onPressed: () {
                        Fluttertoast.showToast(msg: "Added to cart");
                      },
                      icon: const Icon(
                        Icons.add_shopping_cart,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
