/// Default role assigned to every newly registered user.
const String hubDefaultRole = 'farmer';

/// Role that can author articles on the Hub (extension officers / growers).
const String hubPanuluyanRole = 'panuluyan';

/// Public profile of a Cakobean user, mirroring the `users` table in
/// Supabase. Used to seed demo users and to resolve article/comment authors
/// by their id.
class HubUser {
  final String uid;
  final String firstName;

  /// Optional — omitted entirely when a user has no middle name.
  final String? middleName;
  final String lastName;

  /// Public handle, e.g. "maria_santos". Optional — accounts created before
  /// usernames existed may not have one.
  final String? username;
  final String email;

  /// Photo URL. Null when the user has no picture — UI renders initials.
  final String? avatarUrl;
  final String role;
  final DateTime? createdAt;

  const HubUser({
    required this.uid,
    required this.firstName,
    this.middleName,
    required this.lastName,
    this.username,
    required this.email,
    this.avatarUrl,
    this.role = hubDefaultRole,
    this.createdAt,
  });

  /// "First Last" — the middle name is stored for completeness but never
  /// shown in displayed names (it's optional).
  String get fullName => '$firstName $lastName'.trim();

  /// True when the user has a real uploaded photo.
  bool get hasPhoto => avatarUrl != null && avatarUrl!.isNotEmpty;
}
