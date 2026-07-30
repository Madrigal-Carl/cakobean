import 'package:flutter/material.dart';

import 'package:cakobean/app/theme/app_theme.dart';
import 'profile_row.dart';

/// A titled profile section (e.g. "Basic Information", "Account") with an
/// edit button in the top-right corner and a card listing [rows]. Used
/// only on [ProfilePage].
class ProfileSection extends StatelessWidget {
  final AppThemeExtension ext;
  final String title;
  final List<ProfileRow> rows;
  final VoidCallback? onEdit;

  const ProfileSection({
    super.key,
    required this.ext,
    required this.title,
    required this.rows,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontSize: 16,
                color: ext.cocoa,
              ),
            ),
            IconButton(
              onPressed: onEdit,
              icon: Icon(Icons.edit_outlined, size: 18, color: ext.cocoa50),
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              padding: EdgeInsets.zero,
              style: IconButton.styleFrom(
                backgroundColor: ext.sand,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.x2),
        Container(
          decoration: BoxDecoration(
            color: ext.sand.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++) ...[
                if (i > 0) Divider(height: 1, color: ext.hairline),
                rows[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}
