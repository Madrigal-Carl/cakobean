import 'package:flutter/material.dart';

import 'package:cakobean/app/theme/app_theme.dart';

/// Generic empty/no-results state. Use for empty search results, empty
/// lists, empty inboxes, etc. — just pass the icon and message that fit
/// the page.
class EmptyState extends StatelessWidget {
  final AppThemeExtension ext;
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.ext,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: ext.cocoa50),
            const SizedBox(height: AppSpacing.x3),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: ext.cocoa50,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.x3),
              TextButton(
                onPressed: onAction,
                child: Text(
                  actionLabel!,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.ember,
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
