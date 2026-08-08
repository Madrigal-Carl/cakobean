import 'package:flutter/material.dart';

import 'package:cakobean/app/theme/app_theme.dart';
import 'package:cakobean/shared/widgets/page_header.dart';
import 'package:cakobean/shared/widgets/empty_state.dart';
import 'package:cakobean/shared/widgets/stagger_in.dart';
import '../../data/models/article.dart';
import '../widgets/article_card.dart';
import '../widgets/tag_filter_chip.dart';

class HubPage extends StatefulWidget {
  const HubPage({super.key});

  @override
  State<HubPage> createState() => _HubPageState();
}

class _HubPageState extends State<HubPage> {
  final _searchController = TextEditingController();
  String _query = '';
  ArticleTag? _selectedTag;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ArticleModel> get _filteredArticles {
    var articles = mockHubArticles;

    if (_selectedTag != null) {
      articles = articles.where((a) => a.tags.contains(_selectedTag)).toList();
    }

    if (_query.trim().isNotEmpty) {
      final q = _query.toLowerCase();
      articles = articles
          .where(
            (a) =>
                a.title.toLowerCase().contains(q) ||
                a.description.toLowerCase().contains(q) ||
                a.tags.any((t) => t.label.toLowerCase().contains(q)),
          )
          .toList();
    }

    return articles;
  }

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;
    final articles = _filteredArticles;

    return Scaffold(
      backgroundColor: ext.cream,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            PageHeader(
              ext: ext,
              title: 'Hub',
              subtitle: 'Guides and updates for cacao farmers',
              showSearch: true,
              searchController: _searchController,
              searchHint: 'Search articles',
              onSearchChanged: (value) => setState(() => _query = value),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.x2),
              child: SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.x5,
                  ),
                  itemCount: ArticleTag.values.length + 1,
                  separatorBuilder: (context, i) =>
                      const SizedBox(width: AppSpacing.x2),
                  itemBuilder: (context, i) {
                    if (i == 0) {
                      return TagFilterChip(
                        ext: ext,
                        icon: Icons.apps_rounded,
                        label: 'All',
                        selected: _selectedTag == null,
                        onTap: () => setState(() => _selectedTag = null),
                      );
                    }
                    final tag = ArticleTag.values[i - 1];
                    return TagFilterChip(
                      ext: ext,
                      icon: tag.icon,
                      label: tag.label,
                      selected: _selectedTag == tag,
                      onTap: () => setState(() => _selectedTag = tag),
                    );
                  },
                ),
              ),
            ),
            Expanded(
              child: articles.isEmpty
                  ? EmptyState(
                      ext: ext,
                      icon: Icons.search_off_rounded,
                      message: _query.trim().isEmpty
                          ? 'No articles tagged ${_selectedTag?.label}'
                          : 'No articles match "$_query"',
                      actionLabel: 'Clear filters',
                      onAction: () {
                        _searchController.clear();
                        setState(() {
                          _query = '';
                          _selectedTag = null;
                        });
                      },
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.x5,
                        vertical: AppSpacing.x3,
                      ),
                      itemCount: articles.length,
                      separatorBuilder: (context, i) =>
                          Divider(color: ext.hairline, height: 1),
                      itemBuilder: (context, i) {
                        return StaggerIn(
                          index: i,
                          child: ArticleCard(article: articles[i], ext: ext),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
