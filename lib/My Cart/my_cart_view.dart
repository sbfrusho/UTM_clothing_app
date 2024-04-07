import 'package:flutter/material.dart';
import 'package:shopping_app/controller/cart-model.dart';

class CartScreen extends StatefulWidget {
  final List<CartItem> cartItems;

  const CartScreen({Key? key, required this.cartItems}) : super(key: key);

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late List<int> quantities;

  @override
  void initState() {
    super.initState();
    quantities = List.generate(widget.cartItems.length, (index) => 1);
  }

  @override
  Widget build(BuildContext context) {
    double total = 0;

    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
      ),
      body: ListView.builder(
        itemCount: widget.cartItems.length,
        itemBuilder: (context, index) {
          final cartItem = widget.cartItems[index];
          final quantity = quantities[index];
          total += cartItem.price * quantity;

          print(total);

          return ListTile(
            leading: Image.network(cartItem.imageUrl),
            title: Text(cartItem.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('\$${total.toStringAsFixed(2)}'),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove),
                      onPressed: () {
                        setState(() {
                          if (quantity > 1) {
                            quantities[index]--;
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
                           // Update total price here
                           total = total;
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
          padding: EdgeInsets.all(16),
          child: Text(
            'Total: \$${total.toStringAsFixed(2)}',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
