import 'package:flutter/material.dart';

import 'package:cakobean/app/theme/app_theme.dart';

/// Gradient hero header: title, optional subtitle, optional search field.
/// No back button — meant for top-level tab destinations, not pushed pages.
///
/// The search field is opt-in: leave [showSearch] false (or just omit
/// [searchController]/[onSearchChanged]) for pages that only need a
/// title, e.g. a profile or settings page.
class PageHeader extends StatelessWidget {
  final AppThemeExtension ext;
  final String title;
  final String? subtitle;
  final bool showSearch;
  final TextEditingController? searchController;
  final ValueChanged<String>? onSearchChanged;
  final String searchHint;

  const PageHeader({
    super.key,
    required this.ext,
    required this.title,
    this.subtitle,
    this.showSearch = false,
    this.searchController,
    this.onSearchChanged,
    this.searchHint = 'Search',
  }) : assert(
         !showSearch || (searchController != null && onSearchChanged != null),
         'searchController and onSearchChanged are required when showSearch is true',
       );

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(AppRadius.lg * 1.4),
        bottomRight: Radius.circular(AppRadius.lg * 1.4),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.x5,
          AppSpacing.x5,
          AppSpacing.x5,
          AppSpacing.x5,
        ),
        decoration: BoxDecoration(gradient: ext.primaryGradient),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.x1),
              Text(
                subtitle!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 13,
                ),
              ),
            ],
            if (showSearch) ...[
              const SizedBox(height: AppSpacing.x4),
              Container(
                decoration: BoxDecoration(
                  color: ext.cream,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1F000000),
                      offset: Offset(0, 6),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: TextField(
                  controller: searchController,
                  onChanged: onSearchChanged,
                  style: TextStyle(color: ext.cocoa, fontSize: 14),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: searchHint,
                    hintStyle: TextStyle(color: ext.cocoa50, fontSize: 13),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: ext.cocoa50,
                      size: 20,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.x3,
                      horizontal: AppSpacing.x2,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
