import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import 'package:cakobean/domain/models/auth.dart';

/// Low-level wrapper around Supabase Auth so no other layer of the app imports
/// Supabase directly. Operates on raw Supabase types — mapping to domain models
/// lives in [AuthRepository].
class AuthService {
  AuthService({sb.GoTrueClient? auth})
      : _auth = auth ?? sb.Supabase.instance.client.auth;

  final sb.GoTrueClient _auth;

  /// Emits the current user whenever the auth state changes — sign-in,
  /// sign-out, AND profile updates. Keeps the UI in sync with the latest
  /// session, so the router can redirect immediately.
  Stream<AuthUser?> get userStream => _auth
      .onAuthStateChange
      .map((data) => AuthUser.fromSupabase(data.session?.user));

  /// The user at this exact moment — useful for synchronous checks (routing).
  AuthUser? get currentUser => AuthUser.fromSupabase(_auth.currentUser);

  Future<sb.AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _auth.signInWithPassword(email: email.trim(), password: password);
  }

  /// Creates a new account. [metadata] (e.g. first/last name) is stored on the
  /// auth user and mirrored into the `users` table by [AuthRepository]. When
  /// the project has email confirmation enabled, the returned response has no
  /// session and the user must enter the code from the confirmation
  /// email (see [verifySignupOtp]).
  Future<sb.AuthResponse> registerWithEmail({
    required String email,
    required String password,
    Map<String, dynamic>? metadata,
  }) {
    return _auth.signUp(
      email: email.trim(),
      password: password,
      data: metadata,
    );
  }

  /// Completes a pending sign-up by checking the code the user
  /// received by email. Returns a session (and signed-in user) on success.
  Future<sb.AuthResponse> verifySignupOtp({
    required String email,
    required String token,
  }) {
    return _auth.verifyOTP(
      email: email.trim(),
      token: token.trim(),
      type: sb.OtpType.signup,
    );
  }

  /// Re-sends the sign-up confirmation email (with its code).
  Future<void> resendSignupOtp(String email) {
    return _auth.resend(email: email.trim(), type: sb.OtpType.signup);
  }

  Future<void> signOut() => _auth.signOut();
}
