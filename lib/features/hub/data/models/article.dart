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
  String get label {
    switch (this) {
      case ArticleTag.regenerative:
        return 'Regenerative';
      case ArticleTag.nutrition:
        return 'Nutrition';
      case ArticleTag.cultivation:
        return 'Cultivation';
      case ArticleTag.pests:
        return 'Pests';
      case ArticleTag.diseases:
        return 'Diseases';
      case ArticleTag.harvest:
        return 'Harvest';
      case ArticleTag.weather:
        return 'Weather';
      case ArticleTag.guides:
        return 'Guides';
    }
  }

  IconData get icon {
    switch (this) {
      case ArticleTag.regenerative:
        return Icons.eco_outlined;
      case ArticleTag.nutrition:
        return Icons.local_dining_outlined;
      case ArticleTag.cultivation:
        return Icons.agriculture_outlined;
      case ArticleTag.pests:
        return Icons.bug_report_outlined;
      case ArticleTag.diseases:
        return Icons.coronavirus_outlined;
      case ArticleTag.harvest:
        return Icons.grass_outlined;
      case ArticleTag.weather:
        return Icons.cloud_outlined;
      case ArticleTag.guides:
        return Icons.menu_book_outlined;
    }
  }
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

final mockHubArticles = [
  ArticleModel(
    id: '1',
    title: 'Shade Tree Management for Sustainable Cacao Farming',
    description:
        'How intercropping with native shade trees improves soil health, '
        'moderates temperature swings, and boosts long-term yield stability. '
        'Farmers who paired their cacao rows with native canopy species '
        'reported steadier pod development through dry-season stretches, '
        'and the leaf litter buildup measurably improved topsoil retention '
        'over a single growing cycle.',
    imageUrl: 'https://picsum.photos/seed/cacao1/200/200',
    mediaUrls: [
      'https://picsum.photos/seed/cacao1/800/600',
      'https://picsum.photos/seed/cacao1b/800/600',
      'https://picsum.photos/seed/cacao1c/800/600',
    ],
    tags: [
      ArticleTag.regenerative,
      ArticleTag.cultivation,
      ArticleTag.weather,
      ArticleTag.guides,
    ],
    reactionCount: 128,
    commentCount: 3,
    comments: [
      CommentModel(
        id: 'c1',
        authorName: 'Rosario D.',
        avatarUrl: 'https://i.pravatar.cc/100?img=5',
        text:
            'Tried this on my 2-hectare plot last season, soil moisture held up way better than expected.',
        postedAt: DateTime(2026, 7, 28, 9, 15),
      ),
      CommentModel(
        id: 'c2',
        authorName: 'Ben T.',
        avatarUrl: 'https://i.pravatar.cc/100?img=12',
        text:
            'What spacing did you use between the shade trees and the cacao rows?',
        postedAt: DateTime(2026, 7, 28, 14, 40),
      ),
      CommentModel(
        id: 'c3',
        authorName: 'Marites A.',
        avatarUrl: 'https://i.pravatar.cc/100?img=32',
        text: 'Great breakdown, sharing this with our cooperative.',
        postedAt: DateTime(2026, 7, 29, 8, 2),
      ),
    ],
  ),
  ArticleModel(
    id: '2',
    title: 'How to Identify and Treat Pod Borer in Cacao',
    description:
        'Early warning signs of pod borer infestation and the integrated '
        'pest management steps that keep your pods safe. This guide covers '
        'trap placement, natural predator support, and when a targeted '
        'spray is actually warranted versus when it does more harm than good.',
    imageUrl: 'https://picsum.photos/seed/cacao2/200/200',
    mediaUrls: [
      'https://picsum.photos/seed/cacao2/800/600',
      'https://picsum.photos/seed/cacao2b/800/600',
    ],
    tags: [ArticleTag.pests, ArticleTag.diseases, ArticleTag.guides],
    reactionCount: 342,
    commentCount: 1,
    comments: [
      CommentModel(
        id: 'c4',
        authorName: 'Junjun P.',
        avatarUrl: 'https://i.pravatar.cc/100?img=18',
        text: 'The pheromone trap tip alone saved half my crop this season.',
        postedAt: DateTime(2026, 7, 27, 18, 5),
      ),
    ],
  ),
  ArticleModel(
    id: '3',
    title: 'Post-Harvest Fermentation Techniques',
    description:
        'A step-by-step look at fermentation timing and turning frequency '
        'to develop the flavor precursors buyers pay a premium for.',
    imageUrl: 'https://picsum.photos/seed/cacao3/200/200',
    mediaUrls: ['https://picsum.photos/seed/cacao3/800/600'],
    tags: [ArticleTag.harvest, ArticleTag.guides, ArticleTag.nutrition],
    reactionCount: 89,
    commentCount: 0,
  ),
  ArticleModel(
    id: '4',
    title: 'Improving Yield with Proper Pruning',
    description:
        'Formative and maintenance pruning schedules that open up the '
        'canopy for light and airflow without stressing mature trees.',
    imageUrl: 'https://picsum.photos/seed/cacao4/200/200',
    mediaUrls: ['https://picsum.photos/seed/cacao4/800/600'],
    tags: [ArticleTag.cultivation, ArticleTag.regenerative, ArticleTag.guides],
    reactionCount: 51,
    commentCount: 0,
  ),
  ArticleModel(
    id: '5',
    title: 'Recognizing Black Pod Disease Before It Spreads',
    description:
        'What early lesions look like, why humidity accelerates spread, '
        'and the sanitation routine that limits an outbreak.',
    imageUrl: 'https://picsum.photos/seed/cacao5/200/200',
    mediaUrls: [
      'https://picsum.photos/seed/cacao5/800/600',
      'https://picsum.photos/seed/cacao5b/800/600',
    ],
    tags: [
      ArticleTag.diseases,
      ArticleTag.weather,
      ArticleTag.pests,
      ArticleTag.guides,
    ],
    reactionCount: 1204,
    commentCount: 0,
  ),
  ArticleModel(
    id: '6',
    title: 'Reading Wet-Season Forecasts for Spray Scheduling',
    description:
        'Why timing fungicide applications around rainfall windows matters '
        'more than the calendar, and how to plan around it.',
    imageUrl: 'https://picsum.photos/seed/cacao6/200/200',
    mediaUrls: ['https://picsum.photos/seed/cacao6/800/600'],
    tags: [ArticleTag.weather, ArticleTag.diseases],
    reactionCount: 76,
    commentCount: 0,
  ),
  ArticleModel(
    id: '7',
    title: 'Balancing Soil Nutrients for Healthier Pods',
    description:
        'A practical breakdown of potassium and magnesium ratios and '
        'what deficiency symptoms show up on the leaves first.',
    imageUrl: 'https://picsum.photos/seed/cacao7/200/200',
    mediaUrls: ['https://picsum.photos/seed/cacao7/800/600'],
    tags: [ArticleTag.nutrition, ArticleTag.cultivation],
    reactionCount: 33,
    commentCount: 0,
  ),
  ArticleModel(
    id: '8',
    title: 'A Beginner\'s Guide to Starting a Cacao Nursery',
    description:
        'Everything from seed selection to shade-cloth setup for growers '
        'raising their first batch of seedlings.',
    imageUrl: 'https://picsum.photos/seed/cacao8/200/200',
    mediaUrls: ['https://picsum.photos/seed/cacao8/800/600'],
    tags: [ArticleTag.guides, ArticleTag.cultivation],
    reactionCount: 210,
    commentCount: 0,
  ),
];
