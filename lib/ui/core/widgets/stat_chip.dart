import 'package:flutter/material.dart';

import 'package:cakobean/app/theme/app_theme.dart';

class StatChip extends StatelessWidget {
  final AppThemeExtension ext;
  final IconData icon;
  final String label;

  const StatChip({
    super.key,
    required this.ext,
    required this.icon,
    required this.label,
  });

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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: ext.cocoa50),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: ext.cocoa50,
            ),
          ),
        ],
      ),
    );
  }
}
