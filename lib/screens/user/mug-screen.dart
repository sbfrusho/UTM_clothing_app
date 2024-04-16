import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:shopping_app/const/app-colors.dart';
import 'package:shopping_app/controller/cart-controller.dart';
import 'package:shopping_app/screens/user/home-screen.dart';

import '../../My Cart/my_cart_view.dart';
import '../../controller/cart-model.dart';

class MugScreen extends StatefulWidget {
  const MugScreen({super.key});

  @override
  State<MugScreen> createState() => _MugScreenState();
}

class _MugScreenState extends State<MugScreen> {
  final CartController cartController = Get.find<CartController>();
  List<String> imagesURL = [
    "assets/Cup/cup1.jpg",
    "assets/Cup/cup2.jpg",
    "assets/Cup/cup3.jpeg",
    "assets/Cup/cup4.jpeg",
    "assets/Corporate/cup.jpg"
  ];

  List<bool> isCartItemClicked = List.generate(5, (index) => false);
  List<CartItem> cartItems = [];
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Mug",
            style: TextStyle(color: Colors.white),
          ),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
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
        body: Container(child: content()),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex:
              _selectedIndex, // Set the initial index of the selected item
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
            setState(() {
              _selectedIndex = index; // Update the selected index
            });
            // Perform other actions based on the tapped index
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
                    builder: (context) => CartScreen(cartItems: cartItems),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Premium Coffee\n Mug\nPrice : 35 RM",
                      style: TextStyle(color: Colors.white),
                    ),
                    IconButton(
                      onPressed: () {
                        Fluttertoast.showToast(msg: "Added to cart");
                        setState(() {
                          isCartItemClicked[index] = !isCartItemClicked[index];
                          cartItems.add(CartItem(
                            name: "Premium Coffee Mug",
                            price: 35.0,
                            imageUrl: imagesURL[index],
                          ));
                          cartController.addToCart(CartItem(
                            name: "Premium Coffee Mug",
                            price: 35.0,
                            imageUrl: imagesURL[index],
                          ));
                          
                        });

                        

                      },
                      icon: Icon(
                        Icons.add_shopping_cart,
                        color: isCartItemClicked[index]
                            ? Colors.green[400]
                            : Colors.white,
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
