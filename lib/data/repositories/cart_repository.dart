import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/firestore_paths.dart';
import '../../core/errors/app_exception.dart';
import '../models/cart_item_model.dart';

/// `users/{uid}/cart`. Firestore's offline cache makes the cart available
/// without a connection; writes made offline sync when it returns, and the
/// stream keeps every signed-in device in step.
class CartRepository {
  CartRepository({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _cart(String uid) => _db
      .collection(FirestorePaths.users)
      .doc(uid)
      .collection(FirestorePaths.userCart);

  /// Oldest first, so lines keep their position as quantities change.
  Stream<List<CartItemModel>> watch(String uid) => _cart(uid).snapshots().map(
    (s) => s.docs.map((d) => CartItemModel.fromMap(d.data())).toList()
      ..sort(
        (a, b) => (a.addedAt ?? DateTime(9999)).compareTo(
          b.addedAt ?? DateTime(9999),
        ),
      ),
  );

  Future<void> save(String uid, CartItemModel item, {bool isNew = false}) =>
      _guard(
        () => _cart(uid).doc(item.key).set({
          ...item.toMap(),
          'updatedAt': FieldValue.serverTimestamp(),
          if (isNew) 'addedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true)),
      );

  Future<void> remove(String uid, String key) =>
      _guard(() => _cart(uid).doc(key).delete());

  Future<void> clear(String uid) => _guard(() async {
    final docs = await _cart(uid).get();
    final batch = _db.batch();
    for (final d in docs.docs) {
      batch.delete(d.reference);
    }
    await batch.commit();
  });

  Future<void> _guard(Future<void> Function() run) async {
    try {
      await run();
    } catch (e) {
      throw AppException.from(e);
    }
  }
}
