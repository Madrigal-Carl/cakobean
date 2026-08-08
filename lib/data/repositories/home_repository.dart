import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:cakobean/domain/models/recent_view.dart';

/// Persists the home screen's "recently viewed" article history on the device
/// (SharedPreferences). Stores only article ids + view timestamps; article
/// content is always re-fetched live from Firestore by id.
class HomeRepository {
  HomeRepository({SharedPreferencesAsync? prefs})
      : _prefs = prefs ?? SharedPreferencesAsync();

  final SharedPreferencesAsync _prefs;

  static const _viewsKey = 'recent_article_views';
  static const int maxRecent = 5;

  final StreamController<List<RecentView>> _viewsController =
      StreamController<List<RecentView>>.broadcast();

  /// Most recently viewed articles, newest first. Emits the current value
  /// immediately, then any change.
  Stream<List<RecentView>> watchRecentViews() async* {
    yield await loadRecentViews();
    yield* _viewsController.stream;
  }

  /// Current recently-viewed list, newest first.
  Future<List<RecentView>> loadRecentViews() async {
    final raw = await _prefs.getString(_viewsKey);
    if (raw == null || raw.isEmpty) return const [];
    final views = (jsonDecode(raw) as Map<String, dynamic>)
        .entries
        .map(
          (e) => RecentView(
            articleId: e.key,
            viewedAt: DateTime.fromMillisecondsSinceEpoch(
              (e.value as num).toInt(),
            ),
          ),
        )
        .toList()
      ..sort((a, b) => b.viewedAt.compareTo(a.viewedAt));
    return views.take(maxRecent).toList();
  }

  /// Records that the user opened [articleId], moving it to the front of the
  /// recently-viewed list (deduplicated and capped at [maxRecent]).
  Future<void> recordArticleView(String articleId) async {
    if (articleId.isEmpty) return;
    final views = await loadRecentViews();
    final updated = <RecentView>[
      RecentView(articleId: articleId, viewedAt: DateTime.now()),
      ...views.where((v) => v.articleId != articleId),
    ].take(maxRecent).toList();
    await _prefs.setString(
      _viewsKey,
      jsonEncode({
        for (final v in updated)
          v.articleId: v.viewedAt.millisecondsSinceEpoch,
      }),
    );
    if (_viewsController.hasListener) _viewsController.add(updated);
  }

  void dispose() => _viewsController.close();
}
