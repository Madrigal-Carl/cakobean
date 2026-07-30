/// Model backing a single row in the "Recent Articles" list
/// on the home page.
class RecentArticleModel {
  final String title;
  final String timeAgo;

  const RecentArticleModel({required this.title, required this.timeAgo});
}

/// Temporary mock data until this is wired to a real data source.
const mockRecentArticles = [
  RecentArticleModel(
    title: 'How to Identify and Treat Pod Borer in Cacao',
    timeAgo: '1h ago',
  ),
  RecentArticleModel(
    title: 'Market Update: Cacao Prices Rise 12% This Quarter',
    timeAgo: '4h ago',
  ),
];
