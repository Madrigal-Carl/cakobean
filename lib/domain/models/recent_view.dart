/// A single entry in the home screen's "Recently viewed" list: which article
/// the user opened and when. Only the id + timestamp live on-device; the
/// article's content is always re-fetched live from Firestore by id.
class RecentView {
  final String articleId;
  final DateTime viewedAt;

  const RecentView({required this.articleId, required this.viewedAt});
}
