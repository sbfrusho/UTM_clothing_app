import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../core/config/app_config.dart';
import '../../core/constants/firestore_paths.dart';
import '../../core/errors/app_exception.dart';
import '../../core/services/notification_service.dart';
import '../models/user_model.dart';

/// Firebase Authentication plus the `users/{uid}` profile it owns.
///
/// Profiles are keyed by `uid` only.
class AuthRepository {
  AuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _db = firestore ?? FirebaseFirestore.instance,
       _google = googleSignIn ?? GoogleSignIn.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;
  final GoogleSignIn _google;

  bool _googleReady = false;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection(FirestorePaths.users);

  User? get _current => _auth.currentUser;

  // ---------------------------------------------------------------------------
  // Email and password
  // ---------------------------------------------------------------------------

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

  /// Creates the account and its profile and sends the verification e-mail.
  /// The user stays signed in (unverified) and lands on the verify screen.
  Future<User> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user!;
      await user.updateDisplayName(name);
      await _users
          .doc(user.uid)
          .set(
            UserModel(
              uid: user.uid,
              email: email,
              name: name,
              phone: phone,
            ).toMap(),
          );
      await user.sendEmailVerification();
      return user;
    } catch (e) {
      throw AppException.from(e);
    }
  }

  Future<void> sendVerificationEmail() async {
    try {
      await _current?.sendEmailVerification();
    } catch (e) {
      throw AppException.from(e);
    }
  }

  /// Refreshes the user from the server. Returns whether the email is now
  /// verified. A deleted or disabled account is signed out.
  Future<bool> reloadAndCheckVerified() async {
    final user = _current;
    if (user == null) return false;
    try {
      await user.reload();
      final verified = _auth.currentUser?.emailVerified ?? false;
      // Fresh token so security rules see `email_verified == true`.
      if (verified) await _auth.currentUser?.getIdToken(true);
      return verified;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'user-disabled') {
        await signOut();
      }
      throw AppException.from(e);
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

  // ---------------------------------------------------------------------------
  // Google
  // ---------------------------------------------------------------------------

  /// Signs in with Google. Returns `null` if the user cancels.
  ///
  /// Creates the profile on first sign-in.
  Future<User?> signInWithGoogle() async {
    if (!AppConfig.isGoogleSignInEnabled) {
      throw const AppException('Google sign-in is not available yet.');
    }
    try {
      await _ensureGoogleReady();
      final account = await _google.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) {
        throw const AppException('Google did not return a sign-in token.');
      }
      final result = await _auth.signInWithCredential(
        GoogleAuthProvider.credential(idToken: idToken),
      );
      final user = result.user!;
      await _createProfileIfMissing(user);
      return user;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      throw AppException(
        e.code == GoogleSignInExceptionCode.clientConfigurationError ||
                e.code == GoogleSignInExceptionCode.providerConfigurationError
            ? 'Google sign-in is not configured for this app yet.'
            : 'Google sign-in failed. Please try again.',
        cause: e,
      );
    } catch (e) {
      throw AppException.from(e);
    }
  }

  Future<void> _ensureGoogleReady() async {
    if (_googleReady) return;
    await _google.initialize(serverClientId: AppConfig.googleServerClientId);
    _googleReady = true;
  }

  Future<void> _createProfileIfMissing(User user) async {
    final doc = _users.doc(user.uid);
    final snapshot = await doc.get();
    if (snapshot.exists) {
      await _removeLegacyFields(user.uid);
      return;
    }
    await doc.set(
      UserModel(
        uid: user.uid,
        email: user.email ?? '',
        name: user.displayName ?? '',
        phone: user.phoneNumber ?? '',
      ).toMap(),
    );
  }

  // ---------------------------------------------------------------------------
  // Sign out
  // ---------------------------------------------------------------------------

  /// Detaches this device from push notifications and ends every session.
  Future<void> signOut() async {
    final uid = _current?.uid;
    if (uid != null && Get.isRegistered<NotificationService>()) {
      await Get.find<NotificationService>().detach(uid);
    }
    if (_googleReady) {
      try {
        await _google.signOut();
      } catch (_) {}
    }
    await _auth.signOut();
  }

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
