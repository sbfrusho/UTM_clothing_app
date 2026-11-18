import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../core/constants/firestore_paths.dart';
import '../../core/errors/app_exception.dart';
import '../models/user_model.dart';

class UserRepository {
  UserRepository({FirebaseFirestore? firestore, FirebaseStorage? storage})
    : _db = firestore ?? FirebaseFirestore.instance,
      _storageOverride = storage;

  final FirebaseFirestore _db;
  final FirebaseStorage? _storageOverride;

  FirebaseStorage get _storage => _storageOverride ?? FirebaseStorage.instance;

  Reference _avatarRef(String uid) =>
      _storage.ref('${FirestorePaths.users}/$uid/avatar.jpg');

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      _db.collection(FirestorePaths.users).doc(uid);

  Future<UserModel?> fetch(String uid) async {
    try {
      final snapshot = await _doc(uid).get();
      final data = snapshot.data();
      return data == null ? null : UserModel.fromMap(data, uid: uid);
    } catch (e) {
      throw AppException.from(e);
    }
  }

  Future<void> updateProfile(UserModel user) async {
    try {
      await _doc(user.uid).set(user.toProfileUpdate(), SetOptions(merge: true));
    } catch (e) {
      throw AppException.from(e);
    }
  }

  /// `fcmTokens` holds every signed-in device; `deviceToken` keeps the
  /// latest one for the admin app.
  Future<void> addDeviceToken(String uid, String token) async {
    try {
      await _doc(uid).set({
        'deviceToken': token,
        'fcmTokens': FieldValue.arrayUnion([token]),
      }, SetOptions(merge: true));
    } catch (_) {
      // Non-critical.
    }
  }

  Future<void> removeDeviceToken(String uid, String token) async {
    try {
      final snap = await _doc(uid).get();
      await _doc(uid).update({
        'fcmTokens': FieldValue.arrayRemove([token]),
        if (snap.data()?['deviceToken'] == token) 'deviceToken': '',
      });
    } catch (_) {
      // Offline or no profile; the session still ends.
    }
  }

  // ---------------------------------------------------------------------------
  // Profile photo
  // ---------------------------------------------------------------------------

  /// Uploads a JPEG (already resized by the picker) and stores its URL.
  Future<String> uploadAvatar(String uid, Uint8List jpeg) async {
    try {
      final ref = _avatarRef(uid);
      await ref.putData(jpeg, SettableMetadata(contentType: 'image/jpeg'));
      final url = await ref.getDownloadURL();
      await _doc(uid).set({'photoUrl': url}, SetOptions(merge: true));
      return url;
    } catch (e) {
      throw AppException.from(e);
    }
  }

  Future<void> removeAvatar(String uid) async {
    try {
      await _doc(uid).set({'photoUrl': ''}, SetOptions(merge: true));
      await _avatarRef(uid).delete();
    } on FirebaseException catch (e) {
      if (e.code != 'object-not-found') throw AppException.from(e);
    } catch (e) {
      throw AppException.from(e);
    }
  }

  // ---------------------------------------------------------------------------
  // Account deletion (fallback when the deleteAccount function isn't
  // deployed; the function also anonymises orders)
  // ---------------------------------------------------------------------------

  /// Deletes the profile, its cart, wishlist and addresses, and the photo.
  Future<void> deleteUserData(String uid) async {
    try {
      for (final sub in [
        FirestorePaths.userCart,
        FirestorePaths.userWishlist,
        FirestorePaths.userAddresses,
      ]) {
        final docs = await _doc(uid).collection(sub).get();
        for (final d in docs.docs) {
          await d.reference.delete();
        }
      }
      try {
        await _avatarRef(uid).delete();
      } catch (_) {
        // No photo.
      }
      await _doc(uid).delete();
    } catch (e) {
      throw AppException.from(e);
    }
  }
}
