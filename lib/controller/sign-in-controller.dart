// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class SignInController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  CollectionReference colRef = FirebaseFirestore.instance.collection("users");

  var isPasswordVisible = false.obs;
  String user = "";

  Future<UserCredential?> signInMethod(
    String userEmail,
    String userPassword,
  ) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: userEmail,
        password: userPassword,
      );

      await _removeLegacyPasswordField(userCredential.user!.uid);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Error", e.message.toString());
    }
    return null;
  }

  /// Earlier versions stored the plain-text password in `users/{uid}`.
  /// Remove it on every sign-in so existing accounts get cleaned up.
  Future<void> _removeLegacyPasswordField(String uid) async {
    try {
      await colRef.doc(uid).update({
        'password': FieldValue.delete(),
        'biometricEnabled': FieldValue.delete(),
      });
    } catch (_) {
      // Document may not exist yet; nothing to clean.
    }
  }

  Future<DocumentSnapshot> getUserData(String uid) async {
    return await colRef.doc(uid).get();
  }

  void email(String email) {
    user = email;
  }
}
