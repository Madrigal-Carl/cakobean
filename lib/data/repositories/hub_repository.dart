import 'dart:io';

import 'package:cakobean/data/repositories/auth_repository.dart';
import 'package:cakobean/data/services/hub_service.dart';
import 'package:cakobean/data/services/storage_service.dart';
import 'package:cakobean/domain/models/article.dart';
import 'package:cakobean/domain/models/auth.dart';
import 'package:cakobean/domain/models/comment.dart';
import 'package:cakobean/domain/models/hub_user.dart';
import 'package:cakobean/domain/models/media.dart';

/// Domain-facing repository over [HubService]. Maps raw Supabase rows to
/// [ArticleModel]/[CommentModel] and exposes the like/comment operations the
/// UI needs. UI code never touches Supabase directly.
class HubRepository {
  HubRepository({
    HubService? service,
    AuthRepository? auth,
    StorageService? storage,
  })  : _service = service ?? HubService(),
        _auth = auth ?? AuthRepository(),
        _storage = storage ?? StorageService();

  final HubService _service;
  final AuthRepository _auth;
  final StorageService _storage;

  /// Live list of all articles, newest first.
  Stream<List<ArticleModel>> watchArticles() {
    return _service
        .watchArticles()
        .map((rows) => rows.map(_articleFromRow).toList());
  }

  /// Live newest [limit] articles, limited at the query level so only those
  /// rows are fetched (used by the home screen's "Newest" carousel).
  Stream<List<ArticleModel>> watchNewestArticles(int limit) {
    return _service
        .watchArticles(limit: limit)
        .map((rows) => rows.map(_articleFromRow).toList());
  }

  /// Live single article. Emits a blank article if the row disappears
  /// (e.g. deleted) so the detail page can render a placeholder.
  Stream<ArticleModel> watchArticle(String articleId) {
    return _service.watchArticle(articleId).map(
          (row) => row == null
              ? ArticleModel(
                  id: articleId,
                  title: '',
                  description: '',
                  imageUrl: '',
                  tags: const [],
                )
              : _articleFromRow(row),
        );
  }

  /// Live comments for an article, newest first.
  Stream<List<CommentModel>> watchComments(String articleId) {
    return _service.watchComments(articleId).map(
          (rows) => rows.map(_commentFromRow).toList()
            ..sort((a, b) => b.postedAt.compareTo(a.postedAt)),
        );
  }

  /// Live "current user has liked this article" flag.
  Stream<bool> watchLiked(String articleId) {
    return _service.watchLiked(articleId, currentUserId);
  }

  /// Live comment total, counted from the `comments` table.
  Stream<int> watchCommentCount(String articleId) {
    return _service.watchCommentCount(articleId);
  }

  /// Live like total, counted from the `likes` table.
  Stream<int> watchLikeCount(String articleId) {
    return _service.watchLikeCount(articleId);
  }

  /// Toggles a like for the current user by inserting/deleting their row in
  /// the `likes` table.
  Future<void> toggleLike(String articleId) {
    return _service.toggleLike(articleId, currentUserId);
  }

  /// Adds a comment as the current user and returns it so the UI can show it
  /// immediately while the live stream catches up.
  Future<CommentModel> addComment({
    required String articleId,
    required String text,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Comment text must not be empty.');
    }
    final user = _auth.currentUser;
    final postedAt = DateTime.now();
    final data = <String, dynamic>{
      'author_id': user?.uid ?? _guestUserId,
      'author_name': _authorNameFor(user?.displayName),
      'avatar_url': user?.photoUrl ?? _guestAvatarUrl,
      'text': trimmed,
      'posted_at': postedAt.toUtc().toIso8601String(),
    };
    final id = await _service.addComment(articleId: articleId, data: data);
    return CommentModel(
      id: id,
      authorId: data['author_id'] as String,
      authorName: data['author_name'] as String,
      avatarUrl: data['avatar_url'] as String,
      text: trimmed,
      postedAt: postedAt,
    );
  }

  /// Publishes a new article as the current user: uploads every [media] file
  /// to Supabase Storage (in order), then writes the article row to Postgres
  /// with the permanent public URLs. The live article stream picks it up
  /// automatically, so the Hub page refreshes without any extra work.
  Future<void> createArticle({
    required String title,
    required String description,
    required List<ArticleTag> tags,
    List<PickedMedia> media = const [],
  }) async {
    final authorId = currentUserId;
    if (authorId == _guestUserId) {
      throw StateError('You must be signed in to publish an article.');
    }

    final mediaUrls = <String>[];
    for (final item in media) {
      final url = await _storage.uploadMedia(
        filename: item.name,
        file: File(item.path),
        uid: authorId,
      );
      mediaUrls.add(url);
    }

    await _service.addArticle({
      'title': title.trim(),
      'description': description.trim(),
      'image_url': mediaUrls.isNotEmpty ? mediaUrls.first : '',
      'media_urls': mediaUrls,
      'tags': tags.map((tag) => tag.name).toList(),
      'author_id': authorId,
    });
  }

  /// Live single user, used to resolve an article's author from its
  /// `author_id`. Null when the row doesn't exist (e.g. a deleted user).
  Stream<HubUser?> watchUser(String userId) {
    return _service.watchUser(userId).map(_userFromRow);
  }

  /// Writes (or updates) a user's public profile in the `users` table so
  /// their name/email/avatar can be resolved when they author content.
  Future<void> saveUser(HubUser user) {
    return _service.upsertUser(user.uid, _userToMap(user));
  }

  /// Upserts the currently signed-in user into the `users` table. Called
  /// after registration and sign-in so a real (non-demo) user's profile is
  /// available to resolve their authored content. [firstName]/[middleName]/
  /// [lastName] come from the registration form; otherwise they're derived
  /// from the auth display name (e.g. on later sign-ins).
  Future<void> saveCurrentUser({
    String? firstName,
    String? middleName,
    String? lastName,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await saveUser(
      _userFor(user, firstName: firstName, middleName: middleName, lastName: lastName),
    );
  }

  /// Identity of the person acting on the Hub. Falls back to a guest id when
  /// not signed in so the Hub stays usable, but the app forces login anyway.
  String get currentUserId => _auth.currentUser?.uid ?? _guestUserId;

  // ── Mapping ────────────────────────────────────────────────────────────

  static const _guestUserId = 'guest';

  /// Fallback avatar used when a user has no photo.
  static const defaultAvatarUrl = 'https://i.pravatar.cc/100?img=68';
  static const _guestAvatarUrl = defaultAvatarUrl;

  static String _authorNameFor(String? displayName) {
    final name = displayName?.trim() ?? '';
    return name.isEmpty ? 'Guest' : name;
  }

  /// Builds a [HubUser] from the signed-in auth user. Prefers explicit
  /// [firstName]/[middleName]/[lastName] (registration form); falls back to
  /// splitting the auth display name for users who registered before profiles
  /// existed.
  static HubUser _userFor(
    AuthUser user, {
    String? firstName,
    String? middleName,
    String? lastName,
  }) {
    final parts = (user.displayName ?? '').trim().split(RegExp(r'\s+'));
    final first = (firstName ?? '').trim();
    final middle = (middleName ?? '').trim();
    final last = (lastName ?? '').trim();
    return HubUser(
      uid: user.uid,
      firstName: first.isNotEmpty
          ? first
          : (parts.isNotEmpty ? parts.first : ''),
      middleName: middle.isNotEmpty
          ? middle
          : (parts.length > 2 ? parts[1] : null),
      lastName: last.isNotEmpty ? last : (parts.length > 1 ? parts.last : ''),
      email: user.email,
      avatarUrl: user.photoUrl ?? defaultAvatarUrl,
      createdAt: DateTime.now(),
    );
  }

  static ArticleModel _articleFromRow(Map<String, dynamic> row) {
    return ArticleModel(
      id: row['id'] as String? ?? '',
      title: row['title'] as String? ?? '',
      description: row['description'] as String? ?? '',
      imageUrl: row['image_url'] as String? ?? '',
      mediaUrls: (row['media_urls'] as List<dynamic>? ?? const [])
          .cast<String>(),
      tags: (row['tags'] as List<dynamic>? ?? const [])
          .map((tag) => ArticleTag.values.asNameMap()[tag] ?? ArticleTag.guides)
          .toList(),
      authorId: row['author_id'] as String?,
      createdAt: _parseDateTime(row['created_at']),
    );
  }

  static CommentModel _commentFromRow(Map<String, dynamic> row) {
    return CommentModel(
      id: row['id'] as String? ?? '',
      authorId: row['author_id'] as String?,
      authorName: row['author_name'] as String? ?? 'Guest',
      avatarUrl: row['avatar_url'] as String? ?? _guestAvatarUrl,
      text: row['text'] as String? ?? '',
      postedAt: _parseDateTime(row['posted_at']) ?? DateTime.now(),
    );
  }

  /// Maps a profile for upsert. Only fields with meaningful values are sent:
  /// the sync never writes `role` (managed by admins in the dashboard, never
  /// the client) and never writes empty/null fields, so manual edits made in
  /// the Supabase table editor (middle name, avatar, etc.) survive sign-in.
  static Map<String, dynamic> _userToMap(HubUser user) {
    return {
      if (user.firstName.trim().isNotEmpty) 'first_name': user.firstName,
      if (user.middleName != null && user.middleName!.trim().isNotEmpty)
        'middle_name': user.middleName,
      if (user.lastName.trim().isNotEmpty) 'last_name': user.lastName,
      if (user.email.trim().isNotEmpty) 'email': user.email,
      if (user.avatarUrl.isNotEmpty && user.avatarUrl != defaultAvatarUrl)
        'avatar_url': user.avatarUrl,
    };
  }

  static HubUser? _userFromRow(Map<String, dynamic>? row) {
    if (row == null) return null;
    return HubUser(
      uid: row['id'] as String? ?? '',
      firstName: row['first_name'] as String? ?? '',
      middleName: row['middle_name'] as String?,
      lastName: row['last_name'] as String? ?? '',
      email: row['email'] as String? ?? '',
      avatarUrl: row['avatar_url'] as String? ?? _guestAvatarUrl,
      role: row['role'] as String? ?? hubDefaultRole,
      createdAt: _parseDateTime(row['created_at']),
    );
  }

  static DateTime? _parseDateTime(Object? value) {
    if (value is DateTime) return value.toLocal();
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value)?.toLocal();
    }
    return null;
  }
}
