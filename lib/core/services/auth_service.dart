import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

/// Single source of truth for the signed-in Firebase user.
/// Controllers react to [user] instead of reading FirebaseAuth directly.
class AuthService extends GetxService {
  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;
  final Rxn<User> user = Rxn<User>();
  StreamSubscription<User?>? _sub;

  User? get currentUser => _auth.currentUser;
  String? get uid => _auth.currentUser?.uid;
  String? get email => _auth.currentUser?.email;
  bool get isSignedIn => _auth.currentUser != null;

  @override
  void onInit() {
    super.onInit();
    user.value = _auth.currentUser;
    _sub = _auth.authStateChanges().listen((u) => user.value = u);
  }

  Future<void> signOut() => _auth.signOut();

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
