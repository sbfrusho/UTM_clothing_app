// import 'package:flutter/material.dart';
// import 'package:shopping_app/models/wishlist-model.dart';

// class WishlistController with ChangeNotifier {
//   List<WishListModel> _wishlistItems = [];

//   List<WishListModel> get wishlistItems => _wishlistItems;

//   void addToWishlist(WishListModel item) {
//     _wishlistItems.add(item);
//     notifyListeners();
//   }

//   void removeFromWishlist(int index) {
//     _wishlistItems.removeAt(index);
//     notifyListeners();
//   }
// }
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shopping_app/models/wishlist-model.dart';

class WishlistController extends ChangeNotifier {
  List<WishListModel> _wishlistItems = [];

  List<WishListModel> get wishlistItems => _wishlistItems;

  WishlistController() {
    _loadWishlist();
  }

  void addToWishlist(WishListModel item) {
    _wishlistItems.add(item);
    _saveWishlist();
    notifyListeners();
  }

  void removeFromWishlistById(String productId) {
    _wishlistItems.removeWhere((item) => item.productId == productId);
    _saveWishlist();
    notifyListeners();
  }

  Future<void> _saveWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> wishlistJson =
        _wishlistItems.map((item) => json.encode(item.toMap())).toList();
    prefs.setStringList('wishlist', wishlistJson);
  }

  Future<void> _loadWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? wishlistJson = prefs.getStringList('wishlist');
    if (wishlistJson != null) {
      _wishlistItems = wishlistJson
          .map((item) => WishListModel.fromMap(json.decode(item)))
          .toList();
      notifyListeners();
    }
  }

  Future<void> uploadWishlist(String userId) async {
    final CollectionReference users =
        FirebaseFirestore.instance.collection('users');

    try {
      await users.doc(userId).set({
        'wishlist': _wishlistItems.map((item) => item.toMap()).toList(),
      });
      print('Wishlist uploaded successfully.');
    } catch (error) {
      print('Error uploading wishlist: $error');
    }
  }
}
