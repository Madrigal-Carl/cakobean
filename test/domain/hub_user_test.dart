import 'package:test/test.dart';

import 'package:cakobean/domain/models/hub_user.dart';

void main() {
  const base = HubUser(
    uid: 'uid',
    firstName: 'Maria',
    lastName: 'Santos',
    email: 'maria@example.com',
  );

  group('HubUser.hasPhoto', () {
    test('is false when no avatar URL is set', () {
      expect(base.hasPhoto, isFalse);
    });

    test('is false for an empty avatar URL', () {
      const user = HubUser(
        uid: 'uid',
        firstName: 'Maria',
        lastName: 'Santos',
        email: 'maria@example.com',
        avatarUrl: '',
      );
      expect(user.hasPhoto, isFalse);
    });

    test('is true for a real uploaded photo URL', () {
      const user = HubUser(
        uid: 'uid',
        firstName: 'Maria',
        lastName: 'Santos',
        email: 'maria@example.com',
        avatarUrl: 'https://example.com/uid/avatar.jpg',
      );
      expect(user.hasPhoto, isTrue);
    });
  });
}
