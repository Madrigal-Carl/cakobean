import 'package:flutter/material.dart';

import 'package:cakobean/app/theme/app_theme.dart';

/// Circular gradient FAB. Reusable across any page — pass a different
/// [icon] for non-"add" actions (e.g. Icons.edit_rounded) if needed.
class AddButton extends StatelessWidget {
  final AppThemeExtension ext;
  final VoidCallback? onTap;
  final IconData icon;
  final double size;

  const AddButton({
    super.key,
    required this.ext,
    this.onTap,
    this.icon = Icons.add_rounded,
    this.size = 56,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: ext.primaryGradient,
            shape: BoxShape.circle,
            boxShadow: ext.buttonShadow,
          ),
          child: Icon(icon, color: Colors.white, size: size * 0.5),
        ),
      ),
    );
  }
}
