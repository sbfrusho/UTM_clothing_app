import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/firestore_paths.dart';
import '../../core/errors/app_exception.dart';
import '../models/wishlist_item_model.dart';

/// Stored as one document per user: `wishlist/{email}` with a `wishlist`
/// array (legacy layout, migrated to `users/{uid}/wishlist` in Sprint 6).
class WishlistRepository {
  WishlistRepository({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _doc(String email) =>
      _db.collection(FirestorePaths.wishlist).doc(email);

  Future<List<WishlistItemModel>> fetch(String email) async {
    try {
      final snapshot = await _doc(email).get();
      final raw = snapshot.data()?['wishlist'];
      if (raw is! List) return const [];
      return raw
          .whereType<Map<Object?, Object?>>()
          .map((m) => WishlistItemModel.fromMap(Map<String, dynamic>.from(m)))
          .toList();
    } catch (e) {
      throw AppException.from(e);
    }
  }

  Future<void> save(String email, List<WishlistItemModel> items) async {
    try {
      await _doc(email).set({'wishlist': items.map((i) => i.toMap()).toList()});
    } catch (e) {
      throw AppException.from(e);
    }
  }
}
