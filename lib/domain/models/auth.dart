import 'package:supabase_flutter/supabase_flutter.dart' as sb;

/// Supabase-authenticated user, mapped into an app-friendly shape.
/// UI never talks to [sb.GoTrueClient] directly — only through [AuthRepository].
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

  /// Maps the Supabase [sb.User] into an [AuthUser]. Returns null when there
  /// is no signed-in user (e.g. on the initial stream emission after sign-out).
  static AuthUser? fromSupabase(sb.User? user) {
    if (user == null) return null;
    final meta = user.userMetadata;
    final first = (meta?['first_name'] as String? ?? '').trim();
    final last = (meta?['last_name'] as String? ?? '').trim();
    final displayName = '$first $last'.trim();
    return AuthUser(
      uid: user.id,
      email: user.email ?? '',
      displayName: displayName.isEmpty ? null : displayName,
      photoUrl: meta?['avatar_url'] as String?,
      emailVerified: user.emailConfirmedAt != null,
    );
  }
}
