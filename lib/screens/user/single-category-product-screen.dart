// ignore_for_file: prefer_const_constructors, use_super_parameters, unused_local_variable, must_be_immutable

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:shopping_app/const/app-colors.dart';
import 'package:shopping_app/controller/cart-controller.dart';
import 'package:shopping_app/controller/cart-model-controller.dart';
import 'package:shopping_app/screens/user/all-category.dart';
import 'package:shopping_app/screens/user/checkout-screen.dart';
import 'package:shopping_app/screens/user/home-screen.dart';
import 'package:shopping_app/screens/user/product-detailscreen.dart';
import 'package:shopping_app/screens/user/settings.dart';
import 'package:shopping_app/screens/user/wish-list.dart';
import '../../My Cart/my_cart_view.dart';
import '../../controller/wishlist-controller.dart';
import '../../models/product-model.dart';

class SingleProductView extends StatelessWidget {
  final String categoryId;
  final String categoryName;
  final CartController cartController = Get.put(CartController());
  final CheckoutScreen checkoutScreen = CheckoutScreen();
  User? user = FirebaseAuth.instance.currentUser;
  SingleProductView(
      {Key? key, required this.categoryId, required this.categoryName})
      : super(key: key);

  WishlistController wishlistController = Get.put(WishlistController());

  @override
  Widget build(BuildContext context) {
    BindingsBuilder(() {
      Get.put(CartController());
    });
    return Scaffold(
      backgroundColor: AppColor().backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColor().colorRed,
        title: Text(categoryName, style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('products')
            .where('categoryId', isEqualTo: categoryId)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("Products not found for this category!"));
          }

          return // Your code with adjustments
              GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 3,
              mainAxisSpacing: 3,
              childAspectRatio: .6, // Adjusted value
            ),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              ProductModel product = ProductModel.fromMap(
                snapshot.data!.docs[index].data() as Map<String, dynamic>,
              );
              return GestureDetector(
                onTap: () {
                  // Navigate to product details screen
                },
                child: Card(
                  elevation: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ProductDetailScreen(productModel: product),
                              ),
                            );
                          },
                          child: CachedNetworkImage(
                            height: MediaQuery.of(context).size.height * 0.2,
                            width: MediaQuery.of(context).size.width * 0.5,
                            imageUrl: product.productImages[0],
                            placeholder: (context, url) =>
                                CircularProgressIndicator(),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                            fit: BoxFit.fitWidth,
                          ),
                        ), // Placeholder or empty container if URL is null
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.productName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Sale Price: ${product.salePrice} RM',
                              style: TextStyle(fontSize: 14),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Full Price: ${product.fullPrice} RM',
                              style: TextStyle(fontSize: 14),
                            ),
                            SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {
                                if (cartController.cartItems.any((element) =>
                                    element.productId == product.productId)) {
                                  cartController
                                      .removeFromCart(product.productId);
                                  Get.snackbar('Product already in cart',
                                      'Please go to cart to update quantity');
                                  return;
                                } else {
                                  if (product.quantity == "0") {
                                    Fluttertoast.showToast(
                                        msg: "Product is unavailable");
                                  } else {
                                    cartController.email(product.sellerEmail);
                                    cartController.addToCart(
                                      CartItem(
                                        productId: product.productId,
                                        productName: product.productName,
                                        productImage: product.productImages[0],
                                        price: product.salePrice,
                                        quantity: 1,

                                      ),
                                    );
                                    Fluttertoast.showToast(
                                        msg: "Added to cart");
                                  }
                                  // Get.snackbar('Product added to cart', 'You can update quantity in cart');
                                  Fluttertoast.showToast(
                                    msg: "Product added to cart",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                    fontSize: 16.0,
                                  );
                                }
                              },
                              child: Text('Add to Cart'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
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
                MaterialPageRoute(
                  builder: (context) => HomeScreen(),
                ),
              );
              break;
            case 1:
              // Handle the Wishlist item tap
              Navigator.push(context, MaterialPageRoute(builder: (context)=>WishlistScreen()));

              break;
            case 2:
              // Handle the Categories item tap
              Navigator.push(context, MaterialPageRoute(builder: (context)=>AllCategoriesScreen()));
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CartScreen(
                      // cartItems: [],
                      ),
                ),
              );
              break;
            case 4:
              // Handle the Profile item tap
              Navigator.push(context, MaterialPageRoute(builder: (context)=>SettingsScreen(email: user!.email.toString(),)));
              break;
          }
        },
      ),
    );
  }
}
