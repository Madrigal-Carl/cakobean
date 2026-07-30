import 'package:flutter/material.dart';

import 'package:cakobean/app/theme/app_theme.dart';

/// A single "icon + label above value" row, e.g. First Name / Demo.
/// Shows a muted "Not set" placeholder when [value] is null or empty.
/// Used only inside [ProfileInfoSection].
class ProfileRow extends StatelessWidget {
  final AppThemeExtension ext;
  final IconData icon;
  final String label;
  final String? value;

  const ProfileRow({
    super.key,
    required this.ext,
    required this.icon,
    required this.label,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null && value!.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x4,
        vertical: AppSpacing.x3,
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: ext.cocoa50),
          const SizedBox(width: AppSpacing.x3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12.5, color: ext.cocoa50),
                ),
                const SizedBox(height: 2),
                Text(
                  hasValue ? value! : 'Not set',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: hasValue ? ext.cocoa : ext.cocoa50,
                    fontStyle: hasValue ? FontStyle.normal : FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
