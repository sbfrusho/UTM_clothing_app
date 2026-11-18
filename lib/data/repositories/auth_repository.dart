import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/constants/firestore_paths.dart';
import '../../core/errors/app_exception.dart';
import '../models/user_model.dart';

class AuthRepository {
  AuthRepository({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection(FirestorePaths.users);

  Future<User> signIn({required String email, required String password}) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user!;
      await _removeLegacyFields(user.uid);
      return user;
    } catch (e) {
      throw AppException.from(e);
    }
  }

  /// Creates the auth account and profile, sends the verification e-mail and
  /// signs out again (login requires a verified address).
  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    String? deviceToken,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user!;
      await user.sendEmailVerification();
      await _users
          .doc(user.uid)
          .set(
            UserModel(
              uid: user.uid,
              email: email,
              name: name,
              phone: phone,
              deviceToken: deviceToken ?? '',
            ).toMap(),
          );
      await _auth.signOut();
    } catch (e) {
      throw AppException.from(e);
    }
  }

  Future<void> resendVerification({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user?.sendEmailVerification();
      await _auth.signOut();
    } catch (e) {
      throw AppException.from(e);
    }
  }

  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw AppException.from(e);
    }
  }

  Future<void> signOut() => _auth.signOut();

  /// Older versions stored a plain-text password in the profile.
  Future<void> _removeLegacyFields(String uid) async {
    try {
      await _users.doc(uid).update({
        'password': FieldValue.delete(),
        'biometricEnabled': FieldValue.delete(),
      });
    } catch (_) {
      // Profile may not exist; nothing to clean.
    }
  }
}
