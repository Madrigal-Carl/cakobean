import 'package:cakobean/domain/models/article.dart';
import 'package:cakobean/domain/models/comment.dart';
import 'package:cakobean/domain/models/hub_user.dart';

/// Demo users written to the `users` collection on first launch.
const seedHubUsers = [
  HubUser(
    uid: 'demo',
    firstName: 'Demo',
    lastName: 'Farmer',
    email: 'demo@cakobean.app',
    avatarUrl: 'https://i.pravatar.cc/100?img=68',
  ),
  HubUser(
    uid: 'u-rosario',
    firstName: 'Rosario',
    lastName: 'Domingo',
    email: 'rosario@cakobean.app',
    avatarUrl: 'https://i.pravatar.cc/100?img=5',
  ),
  HubUser(
    uid: 'u-ben',
    firstName: 'Ben',
    lastName: 'Tugon',
    email: 'ben@cakobean.app',
    avatarUrl: 'https://i.pravatar.cc/100?img=12',
  ),
  HubUser(
    uid: 'u-marites',
    firstName: 'Marites',
    lastName: 'Aquino',
    email: 'marites@cakobean.app',
    avatarUrl: 'https://i.pravatar.cc/100?img=32',
  ),
  HubUser(
    uid: 'u-junjun',
    firstName: 'Junjun',
    lastName: 'Panganiban',
    email: 'junjun@cakobean.app',
    avatarUrl: 'https://i.pravatar.cc/100?img=18',
  ),
];

/// Demo articles written to the `articles` collection on first launch, each
/// referencing its author by `authorId`. Their comments are written to the
/// top-level `comments` collection (see [seedHubLikes] for likes). `mediaUrls`
/// may mix images and videos — videos are detected by their file extension.
final seedHubArticles = [
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
    authorId: 'u-rosario',
    createdAt: DateTime(2026, 8, 1, 9, 0),
    comments: [
      CommentModel(
        id: 'c1',
        authorId: 'u-rosario',
        authorName: 'Rosario D.',
        avatarUrl: 'https://i.pravatar.cc/100?img=5',
        text:
            'Tried this on my 2-hectare plot last season, soil moisture held up way better than expected.',
        postedAt: DateTime(2026, 7, 28, 9, 15),
      ),
      CommentModel(
        id: 'c2',
        authorId: 'u-ben',
        authorName: 'Ben T.',
        avatarUrl: 'https://i.pravatar.cc/100?img=12',
        text:
            'What spacing did you use between the shade trees and the cacao rows?',
        postedAt: DateTime(2026, 7, 28, 14, 40),
      ),
      CommentModel(
        id: 'c3',
        authorId: 'u-marites',
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
    authorId: 'u-junjun',
    createdAt: DateTime(2026, 7, 30, 8, 0),
    comments: [
      CommentModel(
        id: 'c4',
        authorId: 'u-junjun',
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
        'to develop the flavor precursors buyers pay a premium for. '
        'Watch the video to see the correct heap structure in action.',
    imageUrl: 'https://picsum.photos/seed/cacao3/200/200',
    mediaUrls: [
      'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
      'https://picsum.photos/seed/cacao3/800/600',
    ],
    tags: [ArticleTag.harvest, ArticleTag.guides, ArticleTag.nutrition],
    authorId: 'u-marites',
    createdAt: DateTime(2026, 7, 29, 8, 0),
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
    authorId: 'u-ben',
    createdAt: DateTime(2026, 7, 28, 8, 0),
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
    authorId: 'u-rosario',
    createdAt: DateTime(2026, 7, 27, 8, 0),
  ),
  ArticleModel(
    id: '6',
    title: 'Reading Wet-Season Forecasts for Spray Scheduling',
    description:
        'Why timing fungicide applications around rainfall windows matters '
        'more than the calendar, and how to plan around it. '
        'Includes a short walkthrough of reading the Doppler map.',
    imageUrl: 'https://picsum.photos/seed/cacao6/200/200',
    mediaUrls: [
      'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
      'https://picsum.photos/seed/cacao6/800/600',
      'https://picsum.photos/seed/cacao6b/800/600',
    ],
    tags: [ArticleTag.weather, ArticleTag.diseases],
    authorId: 'u-marites',
    createdAt: DateTime(2026, 7, 26, 8, 0),
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
    authorId: 'u-ben',
    createdAt: DateTime(2026, 7, 25, 8, 0),
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
    authorId: 'demo',
    createdAt: DateTime(2026, 7, 24, 8, 0),
  ),
];

/// Demo likes, mapping article id → user ids that liked it. Seeded as docs in
/// the top-level `likes` collection (id `{articleId}_{userId}`) with
/// `articleId` + `userId` fields. Like counts are derived from that collection
/// at read time, so the "counts" shown by the app are simply `likes` filtered
/// by `articleId`.
final seedHubLikes = <String, List<String>>{
  '1': ['demo', 'u-ben', 'u-marites', 'u-junjun'],
  '2': ['demo', 'u-rosario', 'u-ben', 'u-marites', 'u-junjun'],
  '3': ['demo', 'u-rosario'],
  '4': ['demo', 'u-marites'],
  '5': ['demo', 'u-rosario', 'u-ben', 'u-marites', 'u-junjun'],
  '6': ['demo', 'u-ben'],
  '7': ['u-rosario'],
  '8': ['demo', 'u-ben', 'u-junjun'],
};
