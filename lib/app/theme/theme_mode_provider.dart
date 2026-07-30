import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persistence key for the user's chosen theme mode.
const _kThemeModePrefKey = 'app_theme_mode';

/// Order the toggle button cycles through when tapped.
const List<ThemeMode> kThemeModeCycle = [
  ThemeMode.light,
  ThemeMode.dark,
  ThemeMode.system,
];

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    // Kick off the async restore; state starts at `system` until it resolves.
    _restore();
    return ThemeMode.system;
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kThemeModePrefKey);
    if (saved == null) return;
    state = ThemeMode.values.firstWhere(
      (mode) => mode.name == saved,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kThemeModePrefKey, mode.name);
  }

  /// Cycles Light -> Dark -> System -> Light ...
  Future<void> cycle() async {
    final currentIndex = kThemeModeCycle.indexOf(state);
    final next = kThemeModeCycle[(currentIndex + 1) % kThemeModeCycle.length];
    await setThemeMode(next);
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);