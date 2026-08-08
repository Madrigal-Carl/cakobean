import 'package:firebase_auth/firebase_auth.dart' as fb;

/// Firebase-authenticated user, mapped into an app-friendly shape.
/// UI never talks to [FirebaseAuth] directly — only through [AuthRepository].
class AuthUser {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final bool emailVerified;

  const AuthUser({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.emailVerified = false,
  });

  /// Maps the Firebase [fb.User] into an [AuthUser]. Returns null when there
  /// is no signed-in user (e.g. on the initial stream emission after sign-out).
  static AuthUser? fromFirebase(fb.User? user) {
    if (user == null) return null;
    return AuthUser(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL,
      emailVerified: user.emailVerified,
    );
  }
}
