import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shopping_app/controller/cart-controller.dart';
import 'package:shopping_app/controller/cart-model.dart';
import '../const/app-colors.dart';

class CartScreen extends StatefulWidget {
  final List<CartItem> cartItems;

  const CartScreen({Key? key, required this.cartItems}) : super(key: key);

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartController cartController = Get.find();
  late List<int> quantities;
  double finalTotal = 0;

  @override
  void initState() {
    super.initState();
    quantities = List.generate(cartController.cartItems.length, (index) => 1);
    calculateTotal();
  }

  void calculateTotal() {
    finalTotal = 0;
    for (int i = 0; i < cartController.cartItems.length; i++) {
      finalTotal += cartController.cartItems[i].price * quantities[i];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Cart",
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
      body: ListView.builder(
        itemCount: cartController.cartItems.length,
        itemBuilder: (context, index) {
          final cartItem = cartController.cartItems[index];
          final quantity = quantities[index];

          return ListTile(
            leading: Image(image: AssetImage(cartItem.imageUrl)),
            title: Text(cartItem.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${(cartItem.price * quantity).toStringAsFixed(2)} RM'),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        setState(() {
                          if (quantity > 1) {
                            quantities[index]--;
                            calculateTotal();
                          }
                          else{
                            cartController.cartItems.removeAt(index);
                            quantities.removeAt(index);
                            calculateTotal();
                          }
                        });
                      },
                    ),
                    Text(quantity.toString()),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        setState(() {
                          quantities[index]++;
                          calculateTotal();
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Total: ${finalTotal.toStringAsFixed(2)} RM',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
