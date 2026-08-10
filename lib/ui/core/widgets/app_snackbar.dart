import 'package:flutter/material.dart';

import 'package:cakobean/app/theme/app_theme.dart';

/// Tone of a toast shown via [showAppSnackbar].
enum SnackbarKind {
  /// Neutral notification (e.g. "Editing Account — coming soon").
  info,

  /// Confirmation that an action (create/edit/delete) succeeded.
  success,

  /// Something went wrong.
  error,
}

/// Themed, floating toast used everywhere for simple create/edit/delete
/// notifications. Replaces the previous one-off `ScaffoldMessenger` calls so
/// every screen gets the same rounded, icon-led snackbar. Any currently
/// visible toast is replaced instead of queued.
void showAppSnackbar(
  BuildContext context,
  String message, {
  SnackbarKind kind = SnackbarKind.info,
  Duration duration = const Duration(seconds: 3),
}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: _SnackbarContent(message: message, kind: kind),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        margin: const EdgeInsets.fromLTRB(
          AppSpacing.x5,
          0,
          AppSpacing.x5,
          AppSpacing.x4,
        ),
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        duration: duration,
      ),
    );
}

class _SnackbarContent extends StatelessWidget {
  final String message;
  final SnackbarKind kind;

  const _SnackbarContent({required this.message, required this.kind});

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;
    final error = Theme.of(context).colorScheme.error;

    final (background, icon) = switch (kind) {
      SnackbarKind.info => (ext.cocoa, Icons.info_outline_rounded),
      SnackbarKind.success => (
        const Color(0xFF2E7D32),
        Icons.check_circle_outline_rounded,
      ),
      SnackbarKind.error => (error, Icons.error_outline_rounded),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x4,
        vertical: AppSpacing.x3,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: ext.cardShadow,
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.white),
          const SizedBox(width: AppSpacing.x2),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
