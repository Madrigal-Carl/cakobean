import 'package:flutter/foundation.dart';

@immutable
class CommentModel {
  final String id;
  final String authorName;
  final String avatarUrl;
  final String text;
  final DateTime postedAt;
  final String? authorId;

  const CommentModel({
    required this.id,
    required this.authorName,
    required this.avatarUrl,
    required this.text,
    required this.postedAt,
    this.authorId,
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
