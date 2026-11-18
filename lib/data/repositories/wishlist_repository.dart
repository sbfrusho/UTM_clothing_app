import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/firestore_paths.dart';
import '../../core/errors/app_exception.dart';
import '../../core/utils/app_logger.dart';
import '../models/wishlist_item_model.dart';

/// `users/{uid}/wishlist/{productId}`: one document per saved product, so
/// adding or removing one item can never overwrite the others.
class WishlistRepository {
  WishlistRepository({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _user(String uid) =>
      _db.collection(FirestorePaths.users).doc(uid);

  CollectionReference<Map<String, dynamic>> _items(String uid) =>
      _user(uid).collection(FirestorePaths.userWishlist);

  /// Most recently saved first.
  Stream<List<WishlistItemModel>> watch(String uid) =>
      _items(uid).snapshots().map(
        (s) =>
            s.docs.map((d) => WishlistItemModel.fromMap(d.data())).toList()
              ..sort(
                (a, b) => (b.savedAt ?? DateTime(9999)).compareTo(
                  a.savedAt ?? DateTime(9999),
                ),
              ),
      );

  Future<void> add(String uid, WishlistItemModel item) => _guard(
    () => _items(uid).doc(item.productId).set({
      ...item.toMap(),
      'savedAt': FieldValue.serverTimestamp(),
    }),
  );

  Future<void> remove(String uid, String productId) =>
      _guard(() => _items(uid).doc(productId).delete());

  /// One-time copy of the legacy `wishlist/{email}` array into the new
  /// collection. The legacy document is left untouched (the admin app may
  /// still read it); a flag on the profile stops this running twice.
  Future<void> migrateLegacy({
    required String uid,
    required String email,
  }) async {
    try {
      final profile = await _user(uid).get();
      if (profile.data()?['wishlistMigrated'] == true) return;

      final legacy = await _db
          .collection(FirestorePaths.legacyWishlist)
          .doc(email)
          .get();
      final raw = legacy.data()?['wishlist'];
      final batch = _db.batch();
      if (raw is List) {
        for (final m in raw.whereType<Map<Object?, Object?>>()) {
          final item = WishlistItemModel.fromMap(Map<String, dynamic>.from(m));
          if (item.productId.isEmpty) continue;
          batch.set(_items(uid).doc(item.productId), {
            ...item.toMap(),
            'savedAt': FieldValue.serverTimestamp(),
          });
        }
      }
      batch.set(_user(uid), {
        'wishlistMigrated': true,
      }, SetOptions(merge: true));
      await batch.commit();
    } catch (e, st) {
      // Not fatal: the new wishlist still works; retried next sign-in.
      AppLogger.error('Wishlist migration failed', e, st);
    }
  }

  Future<void> _guard(Future<void> Function() run) async {
    try {
      await run();
    } catch (e) {
      throw AppException.from(e);
    }
  }
}
