// ignore_for_file: prefer_const_constructors, use_super_parameters

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:shopping_app/controller/cart-controller.dart';
import 'package:shopping_app/screens/user/home-screen.dart';
import '../../My Cart/my_cart_view.dart';
import '../../controller/cart-model.dart';
import '../../models/product-model.dart';

class SingleProductView extends StatelessWidget {
  final String categoryId;
  final CartController cartController = Get.put(CartController());

  SingleProductView({Key? key, required this.categoryId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    BindingsBuilder(() {
      Get.put(CartController());
    });
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Details'),
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

          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 3,
              mainAxisSpacing: 3,
              childAspectRatio: 1.3,
            ),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              ProductModel product = ProductModel.fromMap(
                  snapshot.data!.docs[index].data()
                  as Map<String, dynamic>);
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
                        child: CachedNetworkImage(
                          imageUrl: product.productImages[0],
                          placeholder: (context, url) =>
                              CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                          fit: BoxFit.fill,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.productName,
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Sale Price: ${product.salePrice}',
                              style: TextStyle(fontSize: 14),
                            ),
                            SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {
                                // Check if the item is already in the cart
                                bool isInCart = cartController.cartItems.any((item) => item.productId == product.productId); // Replace with actual check
                                if (isInCart) {
                                  cartController.removeFromCart(product.productId);
                                } else {
                                  // Add item to cart
                                  CartItem cartItem = CartItem(
                                    productId: product.productId,
                                    productName: product.productName,
                                    productImage: product.productImages[0],
                                    price: product.salePrice,
                                    quantity: 1,
                                  );
                                  // AddProductToCart(cartItem);
                                  cartController.addToCart(cartItem);
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
                break;
              case 2:
                // Handle the Categories item tap
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
                break;
            }
          },
        ),
    );
  }
}
