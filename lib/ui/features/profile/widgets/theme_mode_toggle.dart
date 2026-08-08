import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cakobean/app/theme/app_theme.dart';
import 'package:cakobean/app/theme/theme_mode_provider.dart';

/// Small pill button that cycles Light -> Dark -> System on tap.
class ThemeModeToggleButton extends ConsumerWidget {
  const ThemeModeToggleButton({super.key});

  (IconData, String) _display(ThemeMode mode) => switch (mode) {
    ThemeMode.light => (Icons.light_mode_outlined, 'Light mode'),
    ThemeMode.dark => (Icons.dark_mode_outlined, 'Dark mode'),
    ThemeMode.system => (Icons.brightness_auto_outlined, 'Device default'),
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;
    final mode = ref.watch(themeModeProvider);
    final (icon, label) = _display(mode);

    return Center(
      child: Material(
        color: ext.sand,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          onTap: () => ref.read(themeModeProvider.notifier).cycle(),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.x4,
              vertical: AppSpacing.x2,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: ext.ember),
                const SizedBox(width: AppSpacing.x2),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: ext.cocoa50,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
