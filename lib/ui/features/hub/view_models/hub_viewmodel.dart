import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cakobean/data/repositories/hub_repository.dart';
import 'package:cakobean/domain/models/article.dart';
import 'package:cakobean/domain/models/comment.dart';
import 'package:cakobean/domain/models/hub_user.dart';
import 'package:cakobean/ui/features/auth/view_models/auth_viewmodel.dart';

/// Provides the single [HubRepository] instance app-wide.
final hubRepositoryProvider = Provider<HubRepository>(
  (ref) => HubRepository(),
);

/// Live article list from Firestore. Because Firestore's on-device cache is
/// enabled, this resolves instantly from cache and re-emits when the network
/// syncs — the Hub works offline and stays in sync across devices.
final hubArticlesProvider = StreamProvider<List<ArticleModel>>(
  (ref) => ref.watch(hubRepositoryProvider).watchArticles(),
);

/// One-time database seed per seed version. No-op when the database is
/// already seeded, so demo data is never duplicated, even across restarts.
/// Kept alive and watched at the app root so it runs once at startup rather
/// than being re-triggered by hub navigation.
final hubSeedProvider = FutureProvider<void>(
  (ref) => ref.watch(hubRepositoryProvider).seedIfNeeded(),
);

/// Identity of the person acting on the Hub (uid used for likes/comments).
final hubCurrentUserIdProvider = Provider<String>(
  (ref) => ref.watch(authStateProvider).value?.uid ?? 'guest',
);

/// Live single article, used by the detail page.
final hubArticleProvider =
    StreamProvider.family<ArticleModel, String>(
      (ref, articleId) =>
          ref.watch(hubRepositoryProvider).watchArticle(articleId),
    );

/// Live single user by id — resolves an article's author from its
/// `authorId` (no name is stored on the article itself).
final hubUserProvider = StreamProvider.family<HubUser?, String>(
  (ref, userId) => ref.watch(hubRepositoryProvider).watchUser(userId),
);

/// Live comments for an article, newest first.
final hubCommentsProvider =
    StreamProvider.family<List<CommentModel>, String>(
      (ref, articleId) =>
          ref.watch(hubRepositoryProvider).watchComments(articleId),
    );

/// Live "current user has liked this article" flag.
final hubLikedProvider = StreamProvider.family<bool, String>(
  (ref, articleId) =>
      ref.watch(hubRepositoryProvider).watchLiked(articleId),
);

/// Live comment total, counted from the article's comments subcollection.
final hubCommentCountProvider = StreamProvider.family<int, String>(
  (ref, articleId) =>
      ref.watch(hubRepositoryProvider).watchCommentCount(articleId),
);

/// Live like total, counted from the article's likes subcollection.
final hubLikeCountProvider = StreamProvider.family<int, String>(
  (ref, articleId) =>
      ref.watch(hubRepositoryProvider).watchLikeCount(articleId),
);
