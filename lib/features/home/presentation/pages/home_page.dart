import 'package:flutter/material.dart';

import 'package:cakobean/app/theme/app_theme.dart';
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
                    Text('Newest Article', style: textTheme.headlineSmall),
                    const SizedBox(height: AppSpacing.x2),
                    const ArticleCarousel(),
                    const SizedBox(height: AppSpacing.x5),
                    Text('Recent Articles', style: textTheme.headlineSmall),
                    const SizedBox(height: AppSpacing.x2),
                    ...mockRecentArticles.map(
                      (a) => RecentArticleTile(article: a, ext: ext),
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
