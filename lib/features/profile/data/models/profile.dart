/// Model backing the profile page. [middleName] and [email] are optional —
/// the UI shows a "Not set" placeholder when they're null or empty.
class ProfileModel {
  final String firstName;
  final String? middleName;
  final String lastName;
  final String username;
  final String? email;

  const ProfileModel({
    required this.firstName,
    this.middleName,
    required this.lastName,
    required this.username,
    this.email,
  });

  String get fullName => '$firstName $lastName';

  String get initials =>
      '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}'
          .toUpperCase();
}

/// Temporary mock data until this is wired to a real data source.
const mockProfile = ProfileModel(
  firstName: 'Demo',
  lastName: 'Farmer',
  username: 'demo',
);
