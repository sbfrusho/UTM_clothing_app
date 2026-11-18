import 'package:firebase_auth/firebase_auth.dart';

/// Error with a message that is safe to show to users.
class AppException implements Exception {
  const AppException(this.message, {this.cause});

  final String message;
  final Object? cause;

  /// Maps Firebase/unknown errors to user-facing messages.
  factory AppException.from(Object error) {
    if (error is AppException) return error;
    if (error is FirebaseAuthException) {
      return AppException(_authMessage(error), cause: error);
    }
    if (error is FirebaseException) {
      final message = switch (error.code) {
        'permission-denied' => 'You do not have permission to do that.',
        'unavailable' => 'No connection. Please check your internet.',
        'not-found' => 'The requested item no longer exists.',
        _ => 'Something went wrong. Please try again.',
      };
      return AppException(message, cause: error);
    }
    return AppException(
      'Something went wrong. Please try again.',
      cause: error,
    );
  }

  static String _authMessage(FirebaseAuthException e) => switch (e.code) {
    'invalid-email' => 'That email address is not valid.',
    'user-disabled' => 'This account has been disabled.',
    'user-not-found' ||
    'wrong-password' ||
    'invalid-credential' => 'Incorrect email or password.',
    'email-already-in-use' => 'An account already exists for that email.',
    'weak-password' => 'Please choose a stronger password.',
    'too-many-requests' => 'Too many attempts. Try again later.',
    'network-request-failed' => 'No connection. Please check your internet.',
    _ => e.message ?? 'Authentication failed.',
  };

  @override
  String toString() => 'AppException: $message';
}
