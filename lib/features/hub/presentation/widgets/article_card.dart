import 'package:flutter/material.dart';

import 'package:cakobean/app/theme/app_theme.dart';
import 'package:cakobean/shared/widgets/stat_chip.dart';
import '../../data/models/article.dart';

/// A single row in the hub's article list: thumbnail + title + description
/// + one [StatChip] per tag. Used only on [HubPage].
class ArticleCard extends StatelessWidget {
  final ArticleModel article;
  final AppThemeExtension ext;
  final VoidCallback? onTap;

  const ArticleCard({
    super.key,
    required this.article,
    required this.ext,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.x3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
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
                  _TagRow(ext: ext, tags: article.tags),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Renders up to 2 tag chips, plus a "+N more" chip if there are more —
/// keeps the tag row to a single line regardless of how many tags an
/// article has. Scrolls horizontally if it doesn't fit.
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

/// "+N more" chip shown when an article has more tags than fit inline.
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
