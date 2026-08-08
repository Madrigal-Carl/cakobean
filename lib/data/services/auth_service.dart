import 'package:firebase_auth/firebase_auth.dart';

/// Low-level wrapper around [FirebaseAuth] so no other layer of the app
/// imports Firebase directly. Operates on raw Firebase types —
/// mapping to domain models lives in [AuthRepository].
class AuthService {
  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  /// Emits the current user whenever it changes — sign-in, sign-out, AND
  /// profile updates (display name/photo). `authStateChanges` only fires on
  /// sign-in state changes, so it can carry a stale display name right after
  /// registration; this stream keeps the UI in sync with the latest profile.
  Stream<User?> get userStream => _auth.idTokenChanges();

  /// The user at this exact moment — useful for synchronous checks (routing).
  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
  }) {
    return _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> updateDisplayName(User user, String displayName) {
    return user.updateDisplayName(displayName.trim());
  }

  Future<void> signOut() => _auth.signOut();
}
