import 'package:flutter/foundation.dart';

/// A comment on an article. Author info is NOT stored on the comment itself:
/// the UI resolves the author's full name and avatar from the `users` table
/// via [authorId], so profile edits are reflected everywhere.
@immutable
class CommentModel {
  final String id;
  final String? authorId;
  final String text;
  final DateTime postedAt;

  const CommentModel({
    required this.id,
    this.authorId,
    required this.text,
    required this.postedAt,
  });
}

/// Rough "2h ago" / "3d ago" formatter — swap for `timeago` package later
/// if you want locale support, but this avoids adding a dependency now.
String timeAgo(DateTime date) {
  final diff = DateTime.now().difference(date);
  return switch (diff) {
    _ when diff >= const Duration(days: 7) =>
      '${(diff.inDays / 7).floor()}w ago',
    _ when diff >= const Duration(days: 1) => '${diff.inDays}d ago',
    _ when diff >= const Duration(hours: 1) => '${diff.inHours}h ago',
    _ when diff >= const Duration(minutes: 1) => '${diff.inMinutes}m ago',
    _ => 'just now',
  };
}
