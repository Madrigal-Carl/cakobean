import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import 'package:cakobean/data/services/supabase_live.dart';

/// Low-level wrapper around Supabase (Postgres + Realtime) for the Hub
/// feature. Deals exclusively in raw rows/maps — no domain model knowledge.
/// Mapping happens in [HubRepository] (data layer).
///
/// All reads are live: lists use PostgREST's `.stream(primaryKey:)`, which
/// fetches once and keeps the list in sync through Realtime; single rows,
/// counts and flags re-fetch on table changes via [supabaseLiveStream]. So
/// likes/comments/articles update in real time across devices.
///
/// Schema (snake_case columns, no stored counters — counts are derived):
/// - `articles` — one row per article, referencing its author by `author_id`.
/// - `comments` — one row per comment, referencing `article_id` + author.
/// - `likes` — one row per (article, user) like, PK (article_id, user_id).
class HubService {
  HubService({sb.SupabaseClient? client})
      : _client = client ?? sb.Supabase.instance.client;

  final sb.SupabaseClient _client;

  /// Live list of articles, newest first. Pass [limit] to only fetch the
  /// latest N rows (used by the home screen's "Newest" carousel).
  Stream<List<Map<String, dynamic>>> watchArticles({int? limit}) {
    var query = _client
        .from('articles')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false);
    if (limit != null && limit > 0) query = query.limit(limit);
    return query;
  }

  /// Live single article row. Emits null when the article doesn't exist.
  Stream<Map<String, dynamic>?> watchArticle(String articleId) {
    return supabaseLiveStream(
      table: 'articles',
      filter: sb.PostgresChangeFilter(
        column: 'id',
        type: sb.PostgresChangeFilterType.eq,
        value: articleId,
      ),
      fetch: () => _client
          .from('articles')
          .select()
          .eq('id', articleId)
          .maybeSingle(),
    );
  }

  /// Live single user row (used to resolve article/comment authors by id).
  /// Emits null when the user doesn't exist.
  Stream<Map<String, dynamic>?> watchUser(String userId) {
    return supabaseLiveStream(
      table: 'users',
      filter: sb.PostgresChangeFilter(
        column: 'id',
        type: sb.PostgresChangeFilterType.eq,
        value: userId,
      ),
      fetch: () => _client
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle(),
    );
  }

  /// Upserts a user's public profile into the `users` table. The primary key
  /// is `id` (the auth user's id); omitted columns are preserved on conflict.
  Future<void> upsertUser(String userId, Map<String, dynamic> data) {
    return _client.from('users').upsert({'id': userId, ...data});
  }

  /// Live comments for an article. Filtered by `article_id`; the caller
  /// sorts newest first.
  Stream<List<Map<String, dynamic>>> watchComments(String articleId) {
    return _client
        .from('comments')
        .stream(primaryKey: ['id'])
        .eq('article_id', articleId);
  }

  /// Live comment total for an article, derived from the `comments` table
  /// (never stored on the article itself), so it can never drift.
  Stream<int> watchCommentCount(String articleId) {
    return supabaseLiveStream(
      table: 'comments',
      filter: sb.PostgresChangeFilter(
        column: 'article_id',
        type: sb.PostgresChangeFilterType.eq,
        value: articleId,
      ),
      fetch: () => _client
          .from('comments')
          .count()
          .eq('article_id', articleId),
    );
  }

  /// Live like total for an article, derived from the `likes` table.
  Stream<int> watchLikeCount(String articleId) {
    return supabaseLiveStream(
      table: 'likes',
      filter: sb.PostgresChangeFilter(
        column: 'article_id',
        type: sb.PostgresChangeFilterType.eq,
        value: articleId,
      ),
      fetch: () => _client.from('likes').count().eq('article_id', articleId),
    );
  }

  /// Live "has this user liked this article" flag. The row's existence IS
  /// the like.
  Stream<bool> watchLiked(String articleId, String userId) {
    return supabaseLiveStream(
      table: 'likes',
      filter: sb.PostgresChangeFilter(
        column: 'article_id',
        type: sb.PostgresChangeFilterType.eq,
        value: articleId,
      ),
      fetch: () async {
        final row = await _client
            .from('likes')
            .select('article_id')
            .eq('article_id', articleId)
            .eq('user_id', userId)
            .maybeSingle();
        return row != null;
      },
    );
  }

  /// Toggles a like by inserting or deleting the (article, user) row.
  Future<void> toggleLike(String articleId, String userId) async {
    final existing = await _client
        .from('likes')
        .select('article_id')
        .eq('article_id', articleId)
        .eq('user_id', userId)
        .maybeSingle();
    if (existing != null) {
      await _client
          .from('likes')
          .delete()
          .eq('article_id', articleId)
          .eq('user_id', userId);
    } else {
      await _client
          .from('likes')
          .insert({'article_id': articleId, 'user_id': userId});
    }
  }

  /// Adds an article and returns its id. `created_at` defaults to now() in
  /// the database, so every device sees the same ordering.
  Future<String> addArticle(Map<String, dynamic> data) async {
    final row = await _client
        .from('articles')
        .insert(data)
        .select('id')
        .single();
    return row['id'] as String;
  }

  /// Adds a comment and returns its id.
  Future<String> addComment({
    required String articleId,
    required Map<String, dynamic> data,
  }) async {
    final row = await _client
        .from('comments')
        .insert({...data, 'article_id': articleId})
        .select('id')
        .single();
    return row['id'] as String;
  }
}
