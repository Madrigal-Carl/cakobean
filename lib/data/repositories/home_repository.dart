import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:cakobean/domain/models/recent_view.dart';

/// Persists the home screen's "recently viewed" article history on the device
/// (SharedPreferences). Stores only article ids + view timestamps; article
/// content is always re-fetched live from Supabase by id. Reactive state on
/// top of this lives in the Riverpod [RecentViewsNotifier].
class HomeRepository {
  HomeRepository({SharedPreferencesAsync? prefs})
      : _prefs = prefs ?? SharedPreferencesAsync();

  final SharedPreferencesAsync _prefs;

  static const _viewsKey = 'recent_article_views';
  static const int maxRecent = 5;

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
  /// recently-viewed list (deduplicated and capped at [maxRecent]). Returns
  /// the updated list so the caller can mirror it into reactive state.
  Future<List<RecentView>> recordArticleView(String articleId) async {
    if (articleId.isEmpty) return loadRecentViews();
    final views = await loadRecentViews();
    final updated = <RecentView>[
      RecentView(articleId: articleId, viewedAt: DateTime.now()),
      ...views.where((v) => v.articleId != articleId),
    ].take(maxRecent).toList();
    await _writeViews(updated);
    return updated;
  }

  /// Clears the recently-viewed history (e.g. when the user signs out).
  Future<void> clearRecentViews() async {
    await _prefs.remove(_viewsKey);
  }

  Future<void> _writeViews(List<RecentView> views) {
    return _prefs.setString(
      _viewsKey,
      jsonEncode({
        for (final v in views)
          v.articleId: v.viewedAt.millisecondsSinceEpoch,
      }),
    );
  }
}
