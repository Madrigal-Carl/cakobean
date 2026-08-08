import 'package:firebase_auth/firebase_auth.dart';

import '../models/auth.dart';

/// Thrown by [AuthRepository] with a human-friendly message for the UI.
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}

/// Wraps all Firebase Auth calls so the rest of the app is decoupled from
/// Firebase. Swap this implementation for another provider later without
/// touching UI code.
class AuthRepository {
  AuthRepository({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  /// Emits the current user whenever the auth state changes (sign-in,
  /// sign-out, token refresh). The single source of truth for "am I logged in".
  Stream<AuthUser?> get userStream =>
      _auth.authStateChanges().map(AuthUser.fromFirebase);

  /// The user at this exact moment — useful for synchronous checks (routing).
  AuthUser? get currentUser => AuthUser.fromFirebase(_auth.currentUser);

  /// Logs in with email + password.
  Future<AuthUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return AuthUser.fromFirebase(credential.user)!;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageFor(e));
    }
  }

  /// Creates a new account and signs in immediately. [displayName] is
  /// optional — a user can fill in their profile later.
  Future<AuthUser> registerWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      if (displayName != null && displayName.trim().isNotEmpty) {
        await credential.user?.updateDisplayName(displayName.trim());
      }
      return AuthUser.fromFirebase(credential.user)!;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageFor(e));
    }
  }

  Future<void> signOut() => _auth.signOut();

  /// Maps common Firebase auth errors to friendly, farmer-facing text.
  static String _messageFor(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'That email address doesn\'t look right.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'operation-not-allowed':
        return 'Sign-up is not enabled yet. In the Firebase console go to '
            'Authentication > Sign-in method and enable "Email/Password".';
      case 'too-many-requests':
        return 'Too many attempts. Try again in a minute.';
      case 'network-request-failed':
        return 'No connection. Check your internet and try again.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
