import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/firestore_paths.dart';
import '../../core/errors/app_exception.dart';
import '../models/user_model.dart';

class UserRepository {
  UserRepository({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

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
}
