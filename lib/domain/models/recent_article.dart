/// Model backing a single row in the "Recent Articles" list
/// on the home page.
class RecentArticleModel {
  final String title;
  final String timeAgo;

  const RecentArticleModel({required this.title, required this.timeAgo});
}
