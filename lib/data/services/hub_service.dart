import 'package:cloud_firestore/cloud_firestore.dart';

/// Low-level wrapper around [FirebaseFirestore] for the Hub feature.
/// Deals exclusively in raw Firestore documents/maps — it has no knowledge
/// of the domain models. Mapping happens in [HubRepository] (data layer).
///
/// All reads use real-time listeners where possible, which is what gives
/// the app instant local updates: Firestore's on-device cache serves reads
/// immediately while the network syncs, so likes/comments feel instant and
/// the Hub works offline.
///
/// Schema (flat collections, no counts stored on the article):
/// - `articles` — the article docs, referencing their author by `authorId`.
/// - `comments` — one doc per comment, referencing its `articleId` + author.
/// - `likes` — one doc per (article, user) like, doc id `{articleId}_{userId}`
///   with `articleId` + `userId` fields.
/// Counts are derived from the `comments`/`likes` collections at read time,
/// so a count can never drift from the data that produces it.
class HubService {
  HubService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _articles =>
      _db.collection('articles');
  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');
  CollectionReference<Map<String, dynamic>> get _comments =>
      _db.collection('comments');
  CollectionReference<Map<String, dynamic>> get _likes =>
      _db.collection('likes');

  DocumentReference<Map<String, dynamic>> _seedMeta() =>
      _db.doc('_meta/hub_seed');

  /// Live list of articles, newest first. Pass [limit] to only fetch the
  /// latest N documents (used by the home screen's "Newest" carousel).
  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> watchArticles({
    int? limit,
  }) {
    var query = _articles.orderBy('createdAt', descending: true);
    if (limit != null && limit > 0) query = query.limit(limit);
    return query.snapshots().map((query) => query.docs);
  }

  /// Live single article document.
  Stream<DocumentSnapshot<Map<String, dynamic>>> watchArticle(
    String articleId,
  ) {
    return _articles.doc(articleId).snapshots();
  }

  /// Live single user document (used to resolve article/comment authors by id).
  Stream<DocumentSnapshot<Map<String, dynamic>>> watchUser(String userId) {
    return _users.doc(userId).snapshots();
  }

  /// Upserts a user's public profile into the `users` collection. Merge keeps
  /// existing fields (like `createdAt`) intact on repeated sign-ins.
  Future<void> upsertUser(String userId, Map<String, dynamic> data) {
    return _users
        .doc(userId)
        .set(data, SetOptions(merge: true));
  }

  /// Live comments for an article. Filtered by `articleId` (single-field
  /// query — no composite index needed); the caller sorts newest first.
  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> watchComments(
    String articleId,
  ) {
    return _comments
        .where('articleId', isEqualTo: articleId)
        .snapshots()
        .map((query) => query.docs);
  }

  /// Live comment total for an article, derived from the `comments` collection
  /// (never stored on the article itself). Listens to the filtered query and
  /// reads the snapshot size, so the total updates in real time and can never
  /// drift from the comments that produce it.
  Stream<int> watchCommentCount(String articleId) {
    return _comments
        .where('articleId', isEqualTo: articleId)
        .snapshots()
        .map((snapshot) => snapshot.size);
  }

  /// Live like total for an article, derived from the `likes` collection.
  Stream<int> watchLikeCount(String articleId) {
    return _likes
        .where('articleId', isEqualTo: articleId)
        .snapshots()
        .map((snapshot) => snapshot.size);
  }

  /// Live "has this user liked this article" flag. One document per
  /// (article, user) in `likes` — its existence IS the like.
  Stream<bool> watchLiked(String articleId, String userId) {
    return _likes
        .doc(_likeId(articleId, userId))
        .snapshots()
        .map((doc) => doc.exists);
  }

  /// Toggles a like for a user by creating/deleting their like document.
  /// The like count is derived from the `likes` collection, so no counter
  /// update is needed and the total can never drift.
  Future<void> toggleLike(String articleId, String userId) {
    final likeRef = _likes.doc(_likeId(articleId, userId));
    return _db.runTransaction((tx) async {
      final likeDoc = await tx.get(likeRef);
      if (likeDoc.exists) {
        tx.delete(likeRef);
      } else {
        tx.set(likeRef, {
          'articleId': articleId,
          'userId': userId,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  /// Adds a comment to the `comments` collection. The comment count is
  /// derived from the collection, so no counter update is needed.
  /// Returns the created document reference so the caller can build a
  /// [CommentModel] with the real id.
  Future<DocumentReference<Map<String, dynamic>>> addComment({
    required String articleId,
    required Map<String, dynamic> data,
  }) {
    return _comments.add(data);
  }

  /// Seeds the database for the current seed [version]. All writes go
  /// through a single atomic batch (including the `_meta/hub_seed` marker),
  /// so either everything is written or nothing is — a half-seeded database
  /// is impossible. Ids are fixed, so re-seeding overwrites with identical
  /// data (idempotent).
  Future<void> seed({
    required int version,
    required List<Map<String, dynamic>> users,
    required List<Map<String, dynamic>> articles,
    required Map<String, List<Map<String, dynamic>>> commentsByArticle,
    required Map<String, List<String>> likesByArticle,
  }) async {
    final batch = _db.batch();
    batch.set(_seedMeta(), {
      'seededAt': FieldValue.serverTimestamp(),
      'version': version,
    });
    for (final user in users) {
      batch.set(_users.doc(user['uid'] as String), user);
    }
    for (final article in articles) {
      final id = article['id'] as String;
      batch.set(
        _articles.doc(id),
        Map<String, dynamic>.from(article)..remove('id'),
      );
    }
    for (final entry in commentsByArticle.entries) {
      for (final comment in entry.value) {
        final id = comment['id'] as String;
        batch.set(
          _comments.doc(id),
          Map<String, dynamic>.from(comment)..remove('id'),
        );
      }
    }
    for (final entry in likesByArticle.entries) {
      for (final userId in entry.value) {
        batch.set(_likes.doc(_likeId(entry.key, userId)), {
          'articleId': entry.key,
          'userId': userId,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    }
    await batch.commit();
  }

  /// Returns the version the database was last seeded with (0 when the seed
  /// marker doesn't exist, i.e. a fresh database).
  Future<int> seedVersion() async {
    final doc = await _seedMeta().get();
    return (doc.data()?['version'] as num?)?.toInt() ?? 0;
  }

  static String _likeId(String articleId, String userId) =>
      '${articleId}_$userId';
}
