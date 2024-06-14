// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shopping_app/const/app-colors.dart';
import 'package:shopping_app/controller/cart-controller.dart';

import '../screens/user/checkout-screen.dart';

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartController cartController = Get.find<CartController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor().colorRed,
        title: Text('Your Cart' , style: TextStyle(color: Colors.white),),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cartController.cartItems.length,
              itemBuilder: (context, index) {
                final item = cartController.cartItems[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: ListTile(
                    tileColor: Colors.grey[200],
                    leading: Image.network(item.productImage),
                    title: Text(item.productName),
                    subtitle: Text(
                      'price : ${(double.parse(item.price)  * item.quantity).toStringAsFixed(2)} RM',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove),
                          onPressed: () {
                            if (item.quantity > 1) {
                              cartController.updateQuantity(
                                  item.productId, item.quantity - 1);
                              setState(() {
                                // Update the UI
                                cartController.update();
                              });
                            } else if (item.quantity < 1) {
                              cartController.removeFromCart(item.productId);
                              setState(() {
                                // Update the UI
                                cartController.update();
                              });
                            } else {
                              cartController.removeFromCart(item.productId);
                              setState(() {
                                // Update the UI
                                cartController.update();
                              });
                            }
                          },
                        ),
                        Text(item.quantity.toString()),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            cartController.updateQuantity(
                                item.productId, item.quantity + 1);
                            setState(() {
                              // Update the UI
                              cartController.update();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: \$${cartController.totalPrice.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Place order logic
                    Navigator.push(context, MaterialPageRoute(builder: (context) => CheckoutScreen()));
                  },
                  child: const Text('Place Order'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
