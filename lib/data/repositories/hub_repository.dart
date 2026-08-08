import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cakobean/data/repositories/auth_repository.dart';
import 'package:cakobean/data/seed/hub_seed.dart';
import 'package:cakobean/data/services/hub_service.dart';
import 'package:cakobean/domain/models/article.dart';
import 'package:cakobean/domain/models/auth.dart';
import 'package:cakobean/domain/models/comment.dart';
import 'package:cakobean/domain/models/hub_user.dart';

/// Domain-facing repository over [HubService]. Maps raw Firestore documents
/// to [ArticleModel]/[CommentModel], seeds the database on first launch, and
/// exposes the like/comment operations the UI needs. UI code never touches
/// Firestore directly.
class HubRepository {
  HubRepository({HubService? service, AuthRepository? auth})
      : _service = service ?? HubService(),
        _auth = auth ?? AuthRepository();

  final HubService _service;
  final AuthRepository _auth;

  /// Live list of all articles, newest first.
  Stream<List<ArticleModel>> watchArticles() {
    return _service
        .watchArticles()
        .map((docs) => docs.map(_articleFromFirestore).toList());
  }

  /// Live newest [limit] articles, limited at the query level so only those
  /// documents are fetched (used by the home screen's "Newest" carousel).
  Stream<List<ArticleModel>> watchNewestArticles(int limit) {
    return _service
        .watchArticles(limit: limit)
        .map((docs) => docs.map(_articleFromFirestore).toList());
  }

  /// Live single article.
  Stream<ArticleModel> watchArticle(String articleId) {
    return _service.watchArticle(articleId).map(_articleFromFirestore);
  }

  /// Live comments for an article, newest first.
  Stream<List<CommentModel>> watchComments(String articleId) {
    return _service
        .watchComments(articleId)
        .map(
          (docs) => docs
              .map(_commentFromFirestore)
              .toList()
            ..sort((a, b) => b.postedAt.compareTo(a.postedAt)),
        );
  }

  /// Live "current user has liked this article" flag.
  Stream<bool> watchLiked(String articleId) {
    return _service.watchLiked(articleId, currentUserId);
  }

  /// Live comment total, counted from the comments subcollection.
  Stream<int> watchCommentCount(String articleId) {
    return _service.watchCommentCount(articleId);
  }

  /// Live like total, counted from the likes subcollection.
  Stream<int> watchLikeCount(String articleId) {
    return _service.watchLikeCount(articleId);
  }

  /// Seeds the database once per seed version. No-op when the database is
  /// already seeded at (or above) the current seed version, so demo data is
  /// never duplicated and schema changes re-seed exactly once. Ids are fixed,
  /// so re-seeding overwrites identical data instead of appending to it.
  Future<void> seedIfNeeded() async {
    try {
      if (await _service.seedVersion() >= _seedVersion) return;
    } on FirebaseException {
      // Can't read the marker (first offline run or restrictive rules) —
      // attempt an idempotent seed anyway; fixed ids make that safe.
    }
    await _service.seed(
      version: _seedVersion,
      users: seedHubUsers.map(_userToMap).toList(),
      articles: seedHubArticles.map(_articleToMap).toList(),
      commentsByArticle: {
        for (final article in seedHubArticles)
          article.id: [
            for (final comment in article.comments)
              _commentToMap(comment, article.id),
          ],
      },
      likesByArticle: seedHubLikes,
    );
  }

  /// Toggles a like for the current user by creating/deleting their like
  /// document in the `likes` collection.
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
      'articleId': articleId,
      'authorId': user?.uid ?? _guestUserId,
      'authorName': _authorNameFor(user?.displayName),
      'avatarUrl': user?.photoUrl ?? _guestAvatarUrl,
      'text': trimmed,
      'postedAt': Timestamp.fromDate(postedAt),
    };
    final ref = await _service.addComment(articleId: articleId, data: data);
    return CommentModel(
      id: ref.id,
      authorId: data['authorId'] as String?,
      authorName: data['authorName'] as String,
      avatarUrl: data['avatarUrl'] as String,
      text: trimmed,
      postedAt: postedAt,
    );
  }

  /// Live single user, used to resolve an article's author from its
  /// `authorId`. Null when the document doesn't exist (e.g. a deleted user).
  Stream<HubUser?> watchUser(String userId) {
    return _service.watchUser(userId).map(_userFromFirestore);
  }

  /// Writes (or updates) a user's public profile in the `users` collection so
  /// their name/email/avatar can be resolved when they author content.
  Future<void> saveUser(HubUser user) {
    return _service.upsertUser(user.uid, _userToMap(user));
  }

  /// Upserts the currently signed-in user into the `users` collection. Called
  /// after registration and sign-in so a real (non-demo) user's profile is
  /// available to resolve their authored content. [firstName]/[lastName] come
  /// from the registration form; otherwise they're derived from the auth
  /// display name (e.g. on later sign-ins).
  Future<void> saveCurrentUser({String? firstName, String? lastName}) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await saveUser(_userFor(user, firstName: firstName, lastName: lastName));
  }

  /// Identity of the person acting on the Hub. Falls back to a guest id when
  /// not signed in so the Hub stays usable, but the app forces login anyway.
  String get currentUserId => _auth.currentUser?.uid ?? _guestUserId;

  // ── Mapping ────────────────────────────────────────────────────────────

  static const _guestUserId = 'guest';

  /// Fallback avatar used when a user has no photo.
  static const defaultAvatarUrl = 'https://i.pravatar.cc/100?img=68';
  static const _guestAvatarUrl = defaultAvatarUrl;

  /// Bump this whenever the seed data or its Firestore schema changes so the
  /// database re-seeds once (old rows are overwritten idempotently).
  static const int _seedVersion = 5;

  static String _authorNameFor(String? displayName) {
    final name = displayName?.trim() ?? '';
    return name.isEmpty ? 'Guest' : name;
  }

  /// Builds a [HubUser] from the signed-in auth user. Prefers explicit
  /// [firstName]/[lastName] (registration form); falls back to splitting the
  /// auth display name for users who registered before profiles existed.
  static HubUser _userFor(
    AuthUser user, {
    String? firstName,
    String? lastName,
  }) {
    final parts = (user.displayName ?? '').trim().split(RegExp(r'\s+'));
    final first = (firstName ?? '').trim();
    final last = (lastName ?? '').trim();
    return HubUser(
      uid: user.uid,
      firstName: first.isNotEmpty
          ? first
          : (parts.isNotEmpty ? parts.first : ''),
      lastName: last.isNotEmpty ? last : (parts.length > 1 ? parts.last : ''),
      email: user.email,
      avatarUrl: user.photoUrl ?? defaultAvatarUrl,
      createdAt: DateTime.now(),
    );
  }

  static ArticleModel _articleFromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};
    return ArticleModel(
      id: doc.id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
      mediaUrls: (data['mediaUrls'] as List<dynamic>? ?? const [])
          .cast<String>(),
      tags: (data['tags'] as List<dynamic>? ?? const [])
          .map((tag) => ArticleTag.values.byName(tag as String))
          .toList(),
      authorId: data['authorId'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  static CommentModel _commentFromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return CommentModel(
      id: doc.id,
      authorId: data['authorId'] as String?,
      authorName: data['authorName'] as String? ?? 'Guest',
      avatarUrl: data['avatarUrl'] as String? ?? _guestAvatarUrl,
      text: data['text'] as String? ?? '',
      postedAt: (data['postedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  static Map<String, dynamic> _articleToMap(ArticleModel article) {
    return {
      'id': article.id,
      'title': article.title,
      'description': article.description,
      'imageUrl': article.imageUrl,
      'mediaUrls': article.mediaUrls,
      'tags': article.tags.map((tag) => tag.name).toList(),
      'authorId': article.authorId,
      'createdAt':
          article.createdAt != null ? Timestamp.fromDate(article.createdAt!) : null,
    };
  }

  static Map<String, dynamic> _commentToMap(
    CommentModel comment,
    String articleId,
  ) {
    return {
      'id': comment.id,
      'articleId': articleId,
      'authorId': comment.authorId,
      'authorName': comment.authorName,
      'avatarUrl': comment.avatarUrl,
      'text': comment.text,
      'postedAt': Timestamp.fromDate(comment.postedAt),
    };
  }

  static Map<String, dynamic> _userToMap(HubUser user) {
    return {
      'uid': user.uid,
      'firstName': user.firstName,
      'lastName': user.lastName,
      'email': user.email,
      'avatarUrl': user.avatarUrl,
      'role': user.role,
      'createdAt': user.createdAt != null
          ? Timestamp.fromDate(user.createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  static HubUser? _userFromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    if (!doc.exists) return null;
    final data = doc.data() ?? const <String, dynamic>{};
    return HubUser(
      uid: doc.id,
      firstName: data['firstName'] as String? ?? '',
      lastName: data['lastName'] as String? ?? '',
      email: data['email'] as String? ?? '',
      avatarUrl: data['avatarUrl'] as String? ?? _guestAvatarUrl,
      role: data['role'] as String? ?? hubDefaultRole,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
