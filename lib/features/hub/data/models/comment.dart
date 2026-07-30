import 'package:flutter/foundation.dart';

@immutable
class CommentModel {
  final String id;
  final String authorName;
  final String avatarUrl;
  final String text;
  final DateTime postedAt;

  const CommentModel({
    required this.id,
    required this.authorName,
    required this.avatarUrl,
    required this.text,
    required this.postedAt,
  });
}

/// Rough "2h ago" / "3d ago" formatter — swap for `timeago` package later
/// if you want locale support, but this avoids adding a dependency now.
String timeAgo(DateTime date) {
  final diff = DateTime.now().difference(date);
  if (diff.inDays >= 7) return '${(diff.inDays / 7).floor()}w ago';
  if (diff.inDays >= 1) return '${diff.inDays}d ago';
  if (diff.inHours >= 1) return '${diff.inHours}h ago';
  if (diff.inMinutes >= 1) return '${diff.inMinutes}m ago';
  return 'just now';
}
