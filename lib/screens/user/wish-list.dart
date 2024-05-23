import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping_app/models/product-model.dart';
import 'package:shopping_app/models/wishlist-model.dart';
import 'package:shopping_app/screens/user/product-detailscreen.dart';
import 'package:shopping_app/controller/wishlist-controller.dart';

class WishlistScreen extends StatelessWidget {
  final List<WishListModel> wishlistItems;

  WishlistScreen({Key? key, required this.wishlistItems}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wishlist'),
      ),
      body: wishlistItems.isEmpty
          ? Center(
              child: Text('Your wishlist is empty.'),
            )
          : ListView.builder(
              itemCount: wishlistItems.length,
              itemBuilder: (context, index) {
                final wishlistItem = wishlistItems[index];
                return ListTile(
                  leading: Image.network(wishlistItem.productImages[0]),
                  title: Text(wishlistItem.productName),
                  subtitle: Text('Price: \$${wishlistItem.salePrice}'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      // Provider.of<WishlistController>(context, listen: false)
                      //     .removeFromWishlist(wishlistItem.productId);
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailScreen(
                          productModel: wishlistItem.toProductModel(),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
