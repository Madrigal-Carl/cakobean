import 'package:flutter/material.dart';

/// Topic tag for a hub article. An article can carry multiple tags.
/// Drives the label + icon shown in each [StatChip] on the article card.
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

/// Model backing a single article card on the hub page.
class ArticleModel {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final List<ArticleTag> tags;

  const ArticleModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.tags,
  });
}

/// Temporary mock data until this is wired to a real data source.
const mockHubArticles = [
  ArticleModel(
    id: '1',
    title: 'Shade Tree Management for Sustainable Cacao Farming',
    description:
        'How intercropping with native shade trees improves soil health, '
        'moderates temperature swings, and boosts long-term yield stability.',
    imageUrl: 'https://picsum.photos/seed/cacao1/200/200',
    tags: [
      ArticleTag.regenerative,
      ArticleTag.cultivation,
      ArticleTag.weather,
      ArticleTag.guides,
    ],
  ),
  ArticleModel(
    id: '2',
    title: 'How to Identify and Treat Pod Borer in Cacao',
    description:
        'Early warning signs of pod borer infestation and the '
        'integrated pest management steps that keep your pods safe.',
    imageUrl: 'https://picsum.photos/seed/cacao2/200/200',
    tags: [ArticleTag.pests, ArticleTag.diseases, ArticleTag.guides],
  ),
  ArticleModel(
    id: '3',
    title: 'Post-Harvest Fermentation Techniques',
    description:
        'A step-by-step look at fermentation timing and turning frequency '
        'to develop the flavor precursors buyers pay a premium for.',
    imageUrl: 'https://picsum.photos/seed/cacao3/200/200',
    tags: [ArticleTag.harvest, ArticleTag.guides, ArticleTag.nutrition],
  ),
  ArticleModel(
    id: '4',
    title: 'Improving Yield with Proper Pruning',
    description:
        'Formative and maintenance pruning schedules that open up the '
        'canopy for light and airflow without stressing mature trees.',
    imageUrl: 'https://picsum.photos/seed/cacao4/200/200',
    tags: [ArticleTag.cultivation, ArticleTag.regenerative, ArticleTag.guides],
  ),
  ArticleModel(
    id: '5',
    title: 'Recognizing Black Pod Disease Before It Spreads',
    description:
        'What early lesions look like, why humidity accelerates spread, '
        'and the sanitation routine that limits an outbreak.',
    imageUrl: 'https://picsum.photos/seed/cacao5/200/200',
    tags: [
      ArticleTag.diseases,
      ArticleTag.weather,
      ArticleTag.pests,
      ArticleTag.guides,
    ],
  ),
  ArticleModel(
    id: '6',
    title: 'Reading Wet-Season Forecasts for Spray Scheduling',
    description:
        'Why timing fungicide applications around rainfall windows matters '
        'more than the calendar, and how to plan around it.',
    imageUrl: 'https://picsum.photos/seed/cacao6/200/200',
    tags: [ArticleTag.weather, ArticleTag.diseases],
  ),
  ArticleModel(
    id: '7',
    title: 'Balancing Soil Nutrients for Healthier Pods',
    description:
        'A practical breakdown of potassium and magnesium ratios and '
        'what deficiency symptoms show up on the leaves first.',
    imageUrl: 'https://picsum.photos/seed/cacao7/200/200',
    tags: [ArticleTag.nutrition, ArticleTag.cultivation],
  ),
  ArticleModel(
    id: '8',
    title: 'A Beginner\'s Guide to Starting a Cacao Nursery',
    description:
        'Everything from seed selection to shade-cloth setup for growers '
        'raising their first batch of seedlings.',
    imageUrl: 'https://picsum.photos/seed/cacao8/200/200',
    tags: [ArticleTag.guides, ArticleTag.cultivation],
  ),
];
