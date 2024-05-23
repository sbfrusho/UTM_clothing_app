import 'package:flutter/material.dart';
import 'package:shopping_app/models/wishlist-model.dart';

class WishlistController extends ChangeNotifier {
  List<WishListModel> _wishlistItems = [];

  // Getter to access the wishlist items
  List<WishListModel> get wishlistItems => _wishlistItems;

  // Add an item to the wishlist
  void addToWishlist(WishListModel item) {
    _wishlistItems.add(item);
    notifyListeners();
  }

  // Remove an item from the wishlist
  void removeFromWishlist(int index) {
    _wishlistItems.removeAt(index);
    notifyListeners();
  }
}
