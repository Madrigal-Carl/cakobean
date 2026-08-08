import 'package:flutter/material.dart';

import 'package:cakobean/app/theme/app_theme.dart';
import 'package:cakobean/shared/widgets/stagger_in.dart';
import '../widgets/home_header.dart';
import '../widgets/article_carousel.dart';
import '../widgets/recent_article.dart';
import '../../data/models/recent_article.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;
    final textTheme = Theme.of(context).textTheme;

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
                    const StaggerIn(index: 1, child: ArticleCarousel()),
                    const SizedBox(height: AppSpacing.x5),
                    StaggerIn(
                      index: 2,
                      child: Text(
                        'Recent Articles',
                        style: textTheme.headlineSmall,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.x2),
                    ...mockRecentArticles.asMap().entries.map(
                      (entry) => StaggerIn(
                        index: entry.key + 3,
                        child: RecentArticleTile(
                          article: entry.value,
                          ext: ext,
                        ),
                      ),
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
