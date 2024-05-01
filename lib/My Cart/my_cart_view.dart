// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shopping_app/controller/cart-controller.dart'; // Adjust import path if necessary
import '../const/app-colors.dart';
import '../controller/cart-model.dart';

class CartScreen extends StatefulWidget {
  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartController cartController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Cart",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.search,
              color: Colors.white,
            ),
            onPressed: () {},
          ),
        ],
        backgroundColor: AppColor().colorRed,
      ),
      body: Obx(
        () => ListView.builder(
          itemCount: cartController.cartItems.length,
          itemBuilder: (context, index) {
            final CartItem cartItem = cartController.cartItems[index];
            final int quantity = cartItem.quantity;

            return ListTile(
              leading: Image.network(cartItem.productImage), // Adjust as necessary
              title: Text(cartItem.productName), // Adjust as necessary
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${(cartItem.price * quantity).toStringAsFixed(2)} RM'),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () {
                          if (quantity > 1) {
                            cartController.decreaseQuantity(index.toString());
                            cartController.update();
                          } else {
                            cartController.removeFromCart(index.toString());
                            cartController.update();
                          }
                        },
                      ),
                      Text(quantity.toString()),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          cartController.increaseQuantity(index.toString());
                          cartController.update();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: Obx(
        () => BottomAppBar(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Total: ${cartController.totalPrice.toStringAsFixed(2)} RM',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
