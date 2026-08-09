import 'package:flutter/material.dart';

import 'package:cakobean/app/theme/app_theme.dart';

/// A single toggleable chip in the hub's tag filter bar. Unlike
/// [StatChip] (read-only display), this has a selected/unselected visual
/// state and an [onTap] handler. Used only on [HubPage].
class TagFilterChip extends StatelessWidget {
  final AppThemeExtension ext;
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const TagFilterChip({
    super.key,
    required this.ext,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: AnimatedContainer(
        duration: AppMotion.fast,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x3,
          vertical: AppSpacing.x1,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.ember : ext.sand,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: selected ? Colors.white : ext.cocoa50),
            const SizedBox(width: AppSpacing.x2),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : ext.cocoa50,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
