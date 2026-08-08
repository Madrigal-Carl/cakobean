import 'package:cakobean/domain/models/comment.dart';
import 'package:test/test.dart';

void main() {
  group('timeAgo', () {
    test('returns "just now" for the current time', () {
      expect(timeAgo(DateTime.now()), 'just now');
    });

    test('returns "just now" for seconds-old timestamps', () {
      expect(timeAgo(DateTime.now().subtract(const Duration(seconds: 30))), 'just now');
    });

    test('formats minutes', () {
      expect(
        timeAgo(DateTime.now().subtract(const Duration(minutes: 5))),
        '5m ago',
      );
    });

    test('formats hours', () {
      expect(
        timeAgo(DateTime.now().subtract(const Duration(hours: 2))),
        '2h ago',
      );
    });

    test('formats days', () {
      expect(
        timeAgo(DateTime.now().subtract(const Duration(days: 3))),
        '3d ago',
      );
    });

    test('formats weeks from a day count', () {
      expect(
        timeAgo(DateTime.now().subtract(const Duration(days: 10))),
        '1w ago',
      );
    });

    test('rounds weeks down', () {
      expect(
        timeAgo(DateTime.now().subtract(const Duration(days: 13))),
        '1w ago',
      );
    });
  });
}
