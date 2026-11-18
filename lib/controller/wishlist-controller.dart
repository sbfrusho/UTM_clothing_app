import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:your_shop/core/utils/app_logger.dart';
import 'package:your_shop/models/wishlist-model.dart';

/// Wishlist state (GetX). Firestore is the source of truth; its offline
/// cache covers no-network use. Moves to `users/{uid}/wishlist` in Sprint 6.
class WishlistController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final RxList<WishListModel> wishlistItems = <WishListModel>[].obs;
  StreamSubscription<User?>? _authSub;

  DocumentReference<Map<String, dynamic>>? get _doc {
    final email = FirebaseAuth.instance.currentUser?.email;
    if (email == null || email.isEmpty) return null;
    return _db.collection('wishlist').doc(email);
  }

  @override
  void onInit() {
    super.onInit();
    // Reload for whoever is signed in; clears on sign-out.
    _authSub = FirebaseAuth.instance
        .authStateChanges()
        .listen((_) => fetchWishlist().catchError((_) {}));
  }

  @override
  void onClose() {
    _authSub?.cancel();
    super.onClose();
  }

  bool contains(String productId) =>
      wishlistItems.any((item) => item.productId == productId);

  Future<void> addToWishlist(WishListModel item) async {
    if (contains(item.productId)) return;
    wishlistItems.add(item);
    await _persist();
  }

  Future<void> removeFromWishlistById(String productId) async {
    wishlistItems.removeWhere((item) => item.productId == productId);
    await _persist();
  }

  Future<void> fetchWishlist() async {
    final doc = _doc;
    if (doc == null) {
      wishlistItems.clear();
      return;
    }
    try {
      final snapshot = await doc.get();
      final raw = (snapshot.data()?['wishlist'] as List<dynamic>?) ?? const [];
      wishlistItems.assignAll(raw
          .map((json) => WishListModel.fromMap(Map<String, dynamic>.from(json)))
          .toList());
    } catch (e, st) {
      AppLogger.error('Error fetching wishlist', e, st);
      rethrow;
    }
  }

  Future<void> updateTimeSlot(WishListModel item, String newTimeSlot) async {
    final index =
        wishlistItems.indexWhere((w) => w.productId == item.productId);
    if (index == -1) return;
    wishlistItems[index].timeSlot = newTimeSlot;
    wishlistItems.refresh();
    await _persist();
  }

  Future<void> _persist() async {
    final doc = _doc;
    if (doc == null) return;
    try {
      await doc.set({
        'wishlist': wishlistItems.map((item) => item.toMap()).toList(),
      });
    } catch (e, st) {
      AppLogger.error('Error saving wishlist', e, st);
    }
  }
}
