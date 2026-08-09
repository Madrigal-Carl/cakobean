import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:cakobean/app/theme/app_theme.dart';
import 'package:cakobean/domain/models/article.dart';
import 'package:cakobean/ui/core/widgets/add_button.dart';
import 'package:cakobean/ui/core/widgets/empty_state.dart';
import 'package:cakobean/ui/core/widgets/page_header.dart';
import 'package:cakobean/ui/core/widgets/stagger_in.dart';
import 'package:cakobean/ui/features/hub/view_models/hub_viewmodel.dart';
import 'package:cakobean/ui/features/hub/widgets/article_card.dart';
import 'package:cakobean/ui/features/hub/widgets/tag_filter_chip.dart';

class HubPage extends ConsumerStatefulWidget {
  const HubPage({super.key});

  @override
  ConsumerState<HubPage> createState() => _HubPageState();
}

class _HubPageState extends ConsumerState<HubPage> {
  final _searchController = TextEditingController();
  String _query = '';
  ArticleTag? _selectedTag;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ArticleModel> _filter(List<ArticleModel> articles) {
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

  void _clearFilters() {
    _searchController.clear();
    setState(() {
      _query = '';
      _selectedTag = null;
    });
  }

  void _retry() {
    ref.invalidate(hubArticlesProvider);
  }

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;
    final articlesAsync = ref.watch(hubArticlesProvider);
    final canAuthor = ref.watch(hubCanAuthorProvider);

    final articles = articlesAsync.value ?? const <ArticleModel>[];
    final filtered = _filter(articles);
    final isInitialLoading = articlesAsync.isLoading && filtered.isEmpty;

    return Scaffold(
      backgroundColor: ext.cream,
      floatingActionButton: canAuthor
          ? AddButton(
              ext: ext,
              onTap: () => context.push('/hub/create-article'),
            )
          : null,
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
                height: 32,
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
              child: switch ((
                isInitialLoading,
                articlesAsync.hasError,
                filtered.isEmpty,
              )) {
                (true, _, _) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                (_, true, _) => EmptyState(
                    ext: ext,
                    icon: Icons.cloud_off_rounded,
                    message:
                        'Could not reach the Hub.\nCheck your connection and try again.',
                    actionLabel: 'Retry',
                    onAction: _retry,
                  ),
                (_, _, true) => EmptyState(
                    ext: ext,
                    icon: Icons.search_off_rounded,
                    message: _query.trim().isEmpty
                        ? _selectedTag == null
                            ? 'No articles yet — pull down to refresh.'
                            : 'No articles tagged ${_selectedTag?.label}'
                        : 'No articles match "$_query"',
                    actionLabel: 'Clear filters',
                    onAction: _clearFilters,
                  ),
                _ => ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.x5,
                      vertical: AppSpacing.x3,
                    ),
                    itemCount: filtered.length,
                    separatorBuilder: (context, i) =>
                        Divider(color: ext.hairline, height: 1),
                    itemBuilder: (context, i) {
                      return StaggerIn(
                        index: i,
                        child: ArticleCard(
                          article: filtered[i],
                          ext: ext,
                        ),
                      );
                    },
                  ),
              },
            ),
          ],
        ),
      ),
    );
  }
}
