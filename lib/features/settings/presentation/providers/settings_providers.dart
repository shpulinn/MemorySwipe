import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/constants/app_constants.dart';

enum AppTheme { dark, light, system }

class SettingsNotifier extends StateNotifier<AppTheme> {
  Box<dynamic> get _box => Hive.box<dynamic>(AppConstants.settingsBoxName);
  static const String _themeKey = 'app_theme';

  SettingsNotifier() : super(AppTheme.dark) {
    _load();
  }

  void _load() {
    final saved = _box.get(_themeKey, defaultValue: 'dark') as String;
    state = AppTheme.values.firstWhere(
      (e) => e.name == saved,
      orElse: () => AppTheme.dark,
    );
  }

  Future<void> setTheme(AppTheme theme) async {
    await _box.put(_themeKey, theme.name);
    state = theme;
  }

  ThemeMode get themeMode {
    switch (state) {
      case AppTheme.dark:
        return ThemeMode.dark;
      case AppTheme.light:
        return ThemeMode.light;
      case AppTheme.system:
        return ThemeMode.system;
    }
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppTheme>((ref) {
  return SettingsNotifier();
});

// Удобный провайдер для ThemeMode
final themeModeProvider = Provider<ThemeMode>((ref) {
  final theme = ref.watch(settingsProvider);
  switch (theme) {
    case AppTheme.dark:
      return ThemeMode.dark;
    case AppTheme.light:
      return ThemeMode.light;
    case AppTheme.system:
      return ThemeMode.system;
  }
});