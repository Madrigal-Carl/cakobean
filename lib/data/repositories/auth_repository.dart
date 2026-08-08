import 'package:firebase_auth/firebase_auth.dart';

import 'package:cakobean/data/services/auth_service.dart';
import 'package:cakobean/domain/models/auth.dart';

/// Thrown by [AuthRepository] with a human-friendly message for the UI.
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}

/// Domain-facing repository over [AuthService]. Maps raw Firebase results
/// into [AuthUser] and translates errors to farmer-friendly text, keeping
/// the UI decoupled from Firebase. Swap the service implementation for
/// another provider later without touching UI code.
class AuthRepository {
  AuthRepository({AuthService? service}) : _service = service ?? AuthService();

  final AuthService _service;

  /// Emits the current user whenever the auth state changes (sign-in,
  /// sign-out, token refresh). The single source of truth for "am I logged in".
  Stream<AuthUser?> get userStream =>
      _service.userStream.map(AuthUser.fromFirebase);

  /// The user at this exact moment — useful for synchronous checks (routing).
  AuthUser? get currentUser => AuthUser.fromFirebase(_service.currentUser);

  /// Logs in with email + password.
  Future<AuthUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _service.signInWithEmail(
        email: email,
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
      final credential = await _service.registerWithEmail(
        email: email,
        password: password,
      );
      if (displayName != null && displayName.trim().isNotEmpty) {
        await _service.updateDisplayName(credential.user!, displayName);
      }
      return AuthUser.fromFirebase(credential.user)!;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageFor(e));
    }
  }

  Future<void> signOut() => _service.signOut();

  /// Maps common Firebase auth errors to friendly, farmer-facing text.
  static String _messageFor(FirebaseAuthException e) {
    return switch (e.code) {
      'invalid-email' => 'That email address doesn\'t look right.',
      'user-disabled' => 'This account has been disabled.',
      'user-not-found' ||
      'wrong-password' ||
      'invalid-credential' => 'Incorrect email or password.',
      'email-already-in-use' => 'An account with this email already exists.',
      'weak-password' => 'Password must be at least 6 characters.',
      'operation-not-allowed' =>
        'Sign-up is not enabled yet. In the Firebase '
            'console go to Authentication > Sign-in method and enable '
            '"Email/Password".',
      'too-many-requests' => 'Too many attempts. Try again in a minute.',
      'network-request-failed' =>
        'No connection. Check your internet and try again.',
      _ => 'Something went wrong. Please try again.',
    };
  }
}
