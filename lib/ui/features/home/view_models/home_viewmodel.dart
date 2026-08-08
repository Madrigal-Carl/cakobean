import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cakobean/data/repositories/home_repository.dart';
import 'package:cakobean/domain/models/article.dart';
import 'package:cakobean/domain/models/recent_view.dart';
import 'package:cakobean/ui/features/hub/view_models/hub_viewmodel.dart';

/// How many latest articles the home screen's "Newest" carousel shows.
const int newestArticleCount = 3;

/// Provides the single [HomeRepository] instance app-wide.
final homeRepositoryProvider = Provider<HomeRepository>(
  (ref) {
    final repo = HomeRepository();
    ref.onDispose(repo.dispose);
    return repo;
  },
);

/// Live "Newest Article" — the [newestArticleCount] most recent articles,
/// limited at the query level so only those documents are fetched.
final newestArticlesProvider = StreamProvider<List<ArticleModel>>(
  (ref) => ref
      .watch(hubRepositoryProvider)
      .watchNewestArticles(newestArticleCount),
);

/// Live recently-viewed article history, newest first (from on-device
/// storage, since that's where the user's viewing history lives).
final recentViewsProvider = StreamProvider<List<RecentView>>(
  (ref) => ref.watch(homeRepositoryProvider).watchRecentViews(),
);

/// A recently-viewed article paired with its (optional) live article data.
/// `article` is null only while that article's stream is loading.
typedef RecentArticleEntry = ({RecentView view, ArticleModel? article});

/// Live recently-viewed articles, newest first. Each entry resolves its
/// article by id, so content is always current even though the history
/// itself lives on-device.
final recentArticlesProvider =
    Provider<AsyncValue<List<RecentArticleEntry>>>(
      (ref) => ref.watch(recentViewsProvider).when(
        loading: () => const AsyncValue.loading(),
        error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
        data: (views) => AsyncValue.data([
          for (final view in views)
            (
              view: view,
              article: ref.watch(hubArticleProvider(view.articleId)).value,
            ),
        ]),
      ),
    );
