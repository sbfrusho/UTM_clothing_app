import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping_app/controller/wishlist-controller.dart';
import 'package:shopping_app/models/wishlist-model.dart';

class WishlistScreen extends StatefulWidget {
  @override
  _WishlistScreenState createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  late Future<void> _wishlistFuture;

  @override
  void initState() {
    super.initState();
    _wishlistFuture = Provider.of<WishlistController>(context, listen: false).fetchWishlist();
  }

  void _showEditDialog(WishListModel item) {
    final TextEditingController timeSlotController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Time Slot'),
          content: TextField(
            controller: timeSlotController,
            decoration: InputDecoration(hintText: "Enter new time slot"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (timeSlotController.text.isNotEmpty) {
                  Provider.of<WishlistController>(context, listen: false)
                      .updateTimeSlot(item, timeSlotController.text);
                  Navigator.of(context).pop();
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Wishlist'),
        backgroundColor: Colors.red,
      ),
      body: FutureBuilder<void>(
        future: _wishlistFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return Consumer<WishlistController>(
              builder: (context, wishlistController, child) {
                if (wishlistController.wishlistItems.isEmpty) {
                  return Center(child: Text('No items in your wishlist.'));
                } else {
                  return ListView.builder(
                    itemCount: wishlistController.wishlistItems.length,
                    itemBuilder: (context, index) {
                      final item = wishlistController.wishlistItems[index];
                      return ListTile(
                        leading: Image.network(
                          item.productImages[0],
                          fit: BoxFit.cover,
                          width: 50,
                          height: 50,
                        ),
                        title: Text(item.productName),
                        subtitle: Text('Sale Price: ${item.salePrice} RM\nTime Slot: ${item.timeSlot}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                _showEditDialog(item);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.remove_circle_outline),
                              onPressed: () {
                                wishlistController.removeFromWishlistById(item.productId);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
              },
            );
          }
        },
      ),
    );
  }
}
