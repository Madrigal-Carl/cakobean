import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:cakobean/app/theme/app_theme.dart';
import 'package:cakobean/domain/models/article.dart';
import 'package:cakobean/ui/core/widgets/stagger_in.dart';
import 'package:cakobean/ui/features/home/view_models/home_viewmodel.dart';
import 'package:cakobean/ui/features/home/widgets/article_carousel.dart';
import 'package:cakobean/ui/features/home/widgets/home_header.dart';
import 'package:cakobean/ui/features/home/widgets/recent_article.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;
    final textTheme = Theme.of(context).textTheme;

    final newestAsync = ref.watch(newestArticlesProvider);
    final recentAsync = ref.watch(recentArticlesProvider);

    return Scaffold(
      backgroundColor: ext.cream,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              HomeHeader(ext: ext),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.x5),
                    StaggerIn(
                      index: 0,
                      child: Text(
                        'Newest Article',
                        style: textTheme.headlineSmall,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.x2),
                    StaggerIn(
                      index: 1,
                      child: _NewestSection(
                        ext: ext,
                        async: newestAsync,
                        onRetry: () =>
                            ref.invalidate(newestArticlesProvider),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.x5),
                    StaggerIn(
                      index: 2,
                      child: Text(
                        'Recent Articles',
                        style: textTheme.headlineSmall,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.x2),
                    _RecentSection(
                      ext: ext,
                      async: recentAsync,
                      onRetry: () => ref.invalidate(recentArticlesProvider),
                    ),
                    const SizedBox(height: AppSpacing.x6),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NewestSection extends StatelessWidget {
  final AppThemeExtension ext;
  final AsyncValue<List<ArticleModel>> async;
  final VoidCallback onRetry;

  const _NewestSection({
    required this.ext,
    required this.async,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return async.when(
      loading: () => const _CarouselPlaceholder(),
      error: (_, _) => _SectionError(ext: ext, onRetry: onRetry),
      data: (articles) => articles.isEmpty
          ? const _CarouselEmpty()
          : ArticleCarousel(articles: articles),
    );
  }
}

class _CarouselPlaceholder extends StatelessWidget {
  const _CarouselPlaceholder();

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;
    return Container(
      height: 150,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: ext.sand,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: const CircularProgressIndicator(strokeWidth: 2),
    );
  }
}

class _CarouselEmpty extends StatelessWidget {
  const _CarouselEmpty();

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;
    return Container(
      height: 150,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: ext.sand,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        'No articles yet',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: ext.cocoa50,
        ),
      ),
    );
  }
}

class _RecentSection extends StatelessWidget {
  final AppThemeExtension ext;
  final AsyncValue<List<RecentArticleEntry>> async;
  final VoidCallback onRetry;

  const _RecentSection({
    required this.ext,
    required this.async,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.x5),
        child: Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      error: (_, _) => _SectionError(ext: ext, onRetry: onRetry),
      data: (entries) => entries.isEmpty
          ? _EmptyRecent(ext: ext)
          : Column(
              children: [
                for (final (i, entry) in entries.indexed)
                  StaggerIn(
                    index: i + 3,
                    child: RecentArticleTile(
                      view: entry.view,
                      article: entry.article,
                      ext: ext,
                    ),
                  ),
              ],
            ),
    );
  }
}

class _EmptyRecent extends StatelessWidget {
  final AppThemeExtension ext;

  const _EmptyRecent({required this.ext});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.x5),
      decoration: BoxDecoration(
        color: ext.sand,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        children: [
          Icon(Icons.explore_outlined, size: 40, color: ext.cocoa50),
          const SizedBox(height: AppSpacing.x3),
          Text(
            'No articles viewed yet',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: ext.cocoa,
            ),
          ),
          const SizedBox(height: AppSpacing.x1),
          Text(
            'Articles you open will show up here.',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(color: ext.cocoa50),
          ),
          const SizedBox(height: AppSpacing.x4),
          FilledButton.icon(
            onPressed: () => context.go('/hub'),
            icon: const Icon(Icons.menu_book_outlined, size: 18),
            label: const Text('Explore articles'),
          ),
        ],
      ),
    );
  }
}

class _SectionError extends StatelessWidget {
  final AppThemeExtension ext;
  final VoidCallback onRetry;

  const _SectionError({required this.ext, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.x5),
      child: Column(
        children: [
          Icon(Icons.cloud_off_outlined, size: 32, color: ext.cocoa50),
          const SizedBox(height: AppSpacing.x2),
          Text(
            "Couldn't load articles.",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: ext.cocoa50,
            ),
          ),
          const SizedBox(height: AppSpacing.x3),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
