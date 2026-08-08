/// Default role assigned to every newly registered user.
const String hubDefaultRole = 'farmer';

/// Public profile of a Cakobean user, mirroring the `users` collection in
/// Firestore. Used to seed demo users and to resolve article/comment authors
/// by their id.
class HubUser {
  final String uid;
  final String firstName;
  final String lastName;
  final String email;
  final String avatarUrl;
  final String role;
  final DateTime? createdAt;

  const HubUser({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.avatarUrl,
    this.role = hubDefaultRole,
    this.createdAt,
  });

  /// "First Last", trimmed so a missing first or last name still renders
  /// cleanly.
  String get fullName => '$firstName $lastName'.trim();
}
