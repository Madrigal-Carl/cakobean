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

/// Live article list from Postgres via Realtime. Fetches once and stays in
/// sync with inserts/updates/deletes, so the Hub updates across devices.
final hubArticlesProvider = StreamProvider<List<ArticleModel>>(
  (ref) => ref.watch(hubRepositoryProvider).watchArticles(),
);

/// Identity of the person acting on the Hub (uid used for likes/comments).
final hubCurrentUserIdProvider = Provider<String>(
  (ref) => ref.watch(authStateProvider).value?.uid ?? 'guest',
);

/// Live profile of the signed-in user from the `users` table, used to
/// resolve their role (e.g. whether they can author articles). Null when
/// signed out or the profile row hasn't been written yet.
final hubCurrentUserProvider = StreamProvider<HubUser?>(
  (ref) {
    final uid = ref.watch(hubCurrentUserIdProvider);
    if (uid == 'guest') return Stream.value(null);
    return ref.watch(hubRepositoryProvider).watchUser(uid);
  },
);

/// Live "current user may author articles" flag, derived from the role stored
/// on their `users` row (set manually in the Supabase table editor for now).
final hubCanAuthorProvider = Provider<bool>(
  (ref) => ref.watch(hubCurrentUserProvider).value?.role == hubPanuluyanRole,
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
