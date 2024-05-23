import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import the WishlistController
import 'package:shopping_app/models/wishlist-model.dart';
import 'package:shopping_app/screens/user/product-detailscreen.dart';

import '../../controller/wishlist-controller.dart';
import '../../models/product-model.dart';

class WishlistScreen extends StatefulWidget {
  final List<WishListModel> wishlistItems; // List of wishlist items
  final ProductModel productModel; // Product model received from the previous screen

  const WishlistScreen({Key? key, required this.wishlistItems, required this.productModel}) : super(key: key);

  @override
  _WishlistScreenState createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wishlist'),
      ),
      body: Consumer<WishlistController>( // Use Consumer to listen to changes in the WishlistController
        builder: (context, wishlistController, _) {
          return widget.wishlistItems.isEmpty
              ? Center(
                  child: Text('Your wishlist is empty.'),
                )
              : ListView.builder(
                  // ListView to display wishlist items
                  itemCount: widget.wishlistItems.length,
                  itemBuilder: (context, index) {
                    final wishlistItem = widget.wishlistItems[index];
                    return ListTile(
                      // Display wishlist item details
                      leading: Image.network(wishlistItem.productImages[0]),
                      title: Text(wishlistItem.productName),
                      subtitle: Text('Price: \$${wishlistItem.salePrice}'),
                      trailing: IconButton(
                        // Remove button
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          // Remove the item from the wishlist using the WishlistController
                          wishlistController.removeFromWishlist(index);
                        },
                      ),
                      onTap: () {
                        // Navigate to the product detail screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailScreen(productModel: widget.productModel),
                          ),
                        );
                      },
                    );
                  },
                );
        },
      ),
    );
  }
}
