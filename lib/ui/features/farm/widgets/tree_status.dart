import 'package:flutter/material.dart';

import 'package:cakobean/app/theme/app_theme.dart';
import 'package:cakobean/domain/models/cacao_tree.dart';

/// UI metadata for a [TreeStatus]: icon, human label, and the theme color
/// that represents it. Colors come from [AppThemeExtension] (or the theme's
/// error scheme) so the tree UI stays consistent with the rest of the app.
typedef TreeStatusMeta = ({IconData icon, String label, Color color});

TreeStatusMeta treeStatusMeta(BuildContext context, TreeStatus status) {
  final ext = Theme.of(context).extension<AppThemeExtension>()!;
  return switch (status) {
    TreeStatus.healthy => (
        icon: Icons.check_circle_rounded,
        label: 'Healthy',
        color: ext.ember,
      ),
    TreeStatus.flowering => (
        icon: Icons.local_florist_outlined,
        label: 'Flowering',
        color: ext.marigold,
      ),
    TreeStatus.fruiting => (
        icon: Icons.cookie_outlined,
        label: 'Fruiting',
        color: ext.pumpkin,
      ),
    TreeStatus.needsCare => (
        icon: Icons.warning_amber_rounded,
        label: 'Needs care',
        color: Theme.of(context).colorScheme.error,
      ),
    TreeStatus.dormant => (
        icon: Icons.ac_unit_rounded,
        label: 'Dormant',
        color: ext.cocoa50,
      ),
  };
}

/// e.g. "Jul 3, 2025" — small manual formatter so we don't need `intl`.
String formatTreeDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}

/// Read-only status pill shown on a tree card. Tapping it ([onTap]) opens the
/// status picker so the tree's status can be updated in one tap.
class TreeStatusPill extends StatelessWidget {
  final AppThemeExtension ext;
  final TreeStatus status;
  final VoidCallback? onTap;

  const TreeStatusPill({
    super.key,
    required this.ext,
    required this.status,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final meta = treeStatusMeta(context, status);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x2,
          vertical: 5,
        ),
        decoration: BoxDecoration(
          color: meta.color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(meta.icon, size: 13, color: meta.color),
            const SizedBox(width: 4),
            Text(
              meta.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: ext.cocoa,
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 2),
              Icon(Icons.expand_more_rounded, size: 15, color: ext.cocoa50),
            ],
          ],
        ),
      ),
    );
  }
}

/// Bottom-sheet list of every [TreeStatus]. Returns the newly selected status
/// (or null when dismissed). Used for one-tap status updates from the tree
/// card.
Future<TreeStatus?> showTreeStatusPicker(
  BuildContext context, {
  required TreeStatus current,
}) {
  return showModalBottomSheet<TreeStatus>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => _TreeStatusPickerSheet(current: current),
  );
}

class _TreeStatusPickerSheet extends StatelessWidget {
  final TreeStatus current;

  const _TreeStatusPickerSheet({required this.current});

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;
    return Container(
      decoration: BoxDecoration(
        color: ext.cream,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.lg),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.x5,
            AppSpacing.x3,
            AppSpacing.x5,
            AppSpacing.x5,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppSpacing.x4),
                  decoration: BoxDecoration(
                    color: ext.hairline,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: ext.sand,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Icon(
                      Icons.agriculture_rounded,
                      color: AppColors.ember,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.x3),
                  Text(
                    'Tree status',
                    style: Theme.of(
                      context,
                    ).textTheme.headlineSmall?.copyWith(color: ext.cocoa),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.x1),
              Text(
                'Choose the current state of this tree.',
                style: TextStyle(fontSize: 13, color: ext.cocoa50),
              ),
              const SizedBox(height: AppSpacing.x4),
              for (final status in TreeStatus.values) ...[
                _StatusOption(
                  status: status,
                  selected: status == current,
                  onTap: () => Navigator.of(context).pop(status),
                ),
                if (status != TreeStatus.values.last)
                  const SizedBox(height: AppSpacing.x1),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusOption extends StatelessWidget {
  final TreeStatus status;
  final bool selected;
  final VoidCallback onTap;

  const _StatusOption({
    required this.status,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;
    final meta = treeStatusMeta(context, status);
    return Material(
      color: selected ? ext.sand : Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.x3,
            vertical: AppSpacing.x3,
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: meta.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(meta.icon, size: 18, color: meta.color),
              ),
              const SizedBox(width: AppSpacing.x3),
              Expanded(
                child: Text(
                  meta.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                    color: ext.cocoa,
                  ),
                ),
              ),
              if (selected)
                Icon(Icons.check_circle_rounded, size: 20, color: AppColors.ember),
            ],
          ),
        ),
      ),
    );
  }
}
