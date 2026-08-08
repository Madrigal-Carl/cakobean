import 'package:flutter/material.dart';

import 'comment.dart';

enum ArticleTag {
  regenerative,
  nutrition,
  cultivation,
  pests,
  diseases,
  harvest,
  weather,
  guides,
}

extension ArticleTagX on ArticleTag {
  String get label => switch (this) {
    ArticleTag.regenerative => 'Regenerative',
    ArticleTag.nutrition => 'Nutrition',
    ArticleTag.cultivation => 'Cultivation',
    ArticleTag.pests => 'Pests',
    ArticleTag.diseases => 'Diseases',
    ArticleTag.harvest => 'Harvest',
    ArticleTag.weather => 'Weather',
    ArticleTag.guides => 'Guides',
  };

  IconData get icon => switch (this) {
    ArticleTag.regenerative => Icons.eco_outlined,
    ArticleTag.nutrition => Icons.local_dining_outlined,
    ArticleTag.cultivation => Icons.agriculture_outlined,
    ArticleTag.pests => Icons.bug_report_outlined,
    ArticleTag.diseases => Icons.coronavirus_outlined,
    ArticleTag.harvest => Icons.grass_outlined,
    ArticleTag.weather => Icons.cloud_outlined,
    ArticleTag.guides => Icons.menu_book_outlined,
  };
}

class ArticleModel {
  final String id;
  final String title;
  final String description;
  final String imageUrl; // thumbnail, used on the hub list card
  final List<String> mediaUrls; // full gallery shown on the detail page
  final List<ArticleTag> tags;
  final int reactionCount;
  final int commentCount;
  final List<CommentModel> comments;

  const ArticleModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    this.mediaUrls = const [],
    required this.tags,
    this.reactionCount = 0,
    this.commentCount = 0,
    this.comments = const [],
  });

  /// Falls back to [imageUrl] if no gallery was provided.
  List<String> get displayMedia =>
      mediaUrls.isNotEmpty ? mediaUrls : [imageUrl];
}
