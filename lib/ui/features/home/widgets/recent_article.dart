import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:cakobean/app/theme/app_theme.dart';
import 'package:cakobean/domain/models/article.dart';
import 'package:cakobean/domain/models/comment.dart';
import 'package:cakobean/domain/models/recent_view.dart';

class RecentArticleTile extends StatelessWidget {
  final RecentView view;
  final ArticleModel? article;
  final AppThemeExtension ext;

  const RecentArticleTile({
    super.key,
    required this.view,
    required this.article,
    required this.ext,
  });

  @override
  Widget build(BuildContext context) {
    final article = this.article;
    final title = article?.title ?? 'Untitled article';

    return InkWell(
      onTap: article == null
          ? null
          : () => context.push('/hub/article/${article.id}', extra: article),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.x3),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: ext.hairline)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.ember,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.x2),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: ext.cocoa,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.x2),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.x2,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: ext.sand,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Text(
                          'Opened',
                          style: TextStyle(
                            fontSize: 11,
                            color: ext.cocoa50,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.x2),
                      Text(
                        timeAgo(view.viewedAt),
                        style: TextStyle(fontSize: 12, color: ext.cocoa50),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
