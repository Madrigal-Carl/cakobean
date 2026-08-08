import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:cakobean/app/theme/app_theme.dart';
import 'package:cakobean/domain/models/article.dart';
import 'package:cakobean/ui/core/widgets/pressable_scale.dart';
import 'package:cakobean/ui/core/widgets/stat_chip.dart';

class ArticleCard extends StatelessWidget {
  final ArticleModel article;
  final AppThemeExtension ext;

  const ArticleCard({super.key, required this.article, required this.ext});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return PressableScale(
      child: InkWell(
        onTap: () => context.push('/hub/article/${article.id}', extra: article),
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.x3),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: 'article-thumb-${article.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: Image.network(
                    article.imageUrl,
                    width: 84,
                    height: 84,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 84,
                      height: 84,
                      color: ext.sand,
                      child: Icon(
                        article.tags.first.icon,
                        color: ext.cocoa50,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.x3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyLarge?.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: ext.cocoa,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.x1),
                    Text(
                      article.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: ext.cocoa50,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.x2),
                    _ArticleStats(
                      ext: ext,
                      reactionCount: article.reactionCount,
                      commentCount: article.commentCount,
                    ),
                    const SizedBox(height: AppSpacing.x2),
                    _TagRow(ext: ext, tags: article.tags),
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

/// Reaction (insightful) + comment counts, left-aligned with [_TagRow]
/// in the article's right-hand text column.
class _ArticleStats extends StatelessWidget {
  final AppThemeExtension ext;
  final int reactionCount;
  final int commentCount;

  const _ArticleStats({
    required this.ext,
    required this.reactionCount,
    required this.commentCount,
  });

  static String _format(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(count % 1000 >= 100 ? 1 : 0)}k';
    }
    return '$count';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StatItem(
          ext: ext,
          icon: Icons.emoji_objects_outlined, // insightful/brain reaction
          count: _format(reactionCount),
        ),
        const SizedBox(width: AppSpacing.x3),
        _StatItem(
          ext: ext,
          icon: Icons.mode_comment_outlined,
          count: _format(commentCount),
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final AppThemeExtension ext;
  final IconData icon;
  final String count;

  const _StatItem({required this.ext, required this.icon, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: ext.cocoa50),
        const SizedBox(width: 4),
        Text(
          count,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: ext.cocoa50,
          ),
        ),
      ],
    );
  }
}

// _TagRow and _MoreTagsChip unchanged from your version.
class _TagRow extends StatelessWidget {
  final AppThemeExtension ext;
  final List<ArticleTag> tags;

  const _TagRow({required this.ext, required this.tags});

  static const int _maxVisible = 2;

  @override
  Widget build(BuildContext context) {
    final visibleTags = tags.take(_maxVisible).toList();
    final extraCount = tags.length - visibleTags.length;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < visibleTags.length; i++) ...[
            if (i > 0) const SizedBox(width: AppSpacing.x1),
            StatChip(
              ext: ext,
              icon: visibleTags[i].icon,
              label: visibleTags[i].label,
            ),
          ],
          if (extraCount > 0) ...[
            const SizedBox(width: AppSpacing.x1),
            _MoreTagsChip(ext: ext, count: extraCount),
          ],
        ],
      ),
    );
  }
}

class _MoreTagsChip extends StatelessWidget {
  final AppThemeExtension ext;
  final int count;

  const _MoreTagsChip({required this.ext, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x2,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: ext.sand,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        '+$count more',
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: ext.cocoa50,
        ),
      ),
    );
  }
}
