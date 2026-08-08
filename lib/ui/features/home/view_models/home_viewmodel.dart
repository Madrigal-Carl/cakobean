import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cakobean/data/repositories/home_repository.dart';
import 'package:cakobean/domain/models/article.dart';
import 'package:cakobean/domain/models/recent_view.dart';
import 'package:cakobean/ui/features/hub/view_models/hub_viewmodel.dart';

/// How many latest articles the home screen's "Newest" carousel shows.
const int newestArticleCount = 3;

/// Provides the single [HomeRepository] instance app-wide.
final homeRepositoryProvider = Provider<HomeRepository>(
  (ref) => HomeRepository(),
);

/// Live "Newest Article" — the [newestArticleCount] most recent articles,
/// limited at the query level so only those documents are fetched.
final newestArticlesProvider = StreamProvider<List<ArticleModel>>(
  (ref) => ref
      .watch(hubRepositoryProvider)
      .watchNewestArticles(newestArticleCount),
);

/// Reactive recently-viewed article history, newest first. Backed by
/// on-device storage (that's where the user's viewing history lives) and
/// surfaced through [HomeRepository] — this notifier is the single owner of
/// the in-app state.
class RecentViewsNotifier extends AsyncNotifier<List<RecentView>> {
  @override
  Future<List<RecentView>> build() {
    return ref.read(homeRepositoryProvider).loadRecentViews();
  }

  /// Records that the user opened [articleId], moving it to the front of the
  /// list. Called from the article detail page.
  Future<void> record(String articleId) async {
    final views = await ref
        .read(homeRepositoryProvider)
        .recordArticleView(articleId);
    state = AsyncValue.data(views);
  }

  /// Clears the history — used when the user signs out so the next account
  /// doesn't inherit the previous one's "recently viewed" list.
  Future<void> clear() async {
    await ref.read(homeRepositoryProvider).clearRecentViews();
    state = const AsyncValue.data([]);
  }
}

final recentViewsProvider =
    AsyncNotifierProvider<RecentViewsNotifier, List<RecentView>>(
      RecentViewsNotifier.new,
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
