import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/constants/app_constants.dart';

enum AppTheme { light, dark }

class SettingsNotifier extends StateNotifier<AppTheme> {
  Box<dynamic> get _box => Hive.box<dynamic>(AppConstants.settingsBoxName);
  static const String _themeKey = 'app_theme';

  SettingsNotifier() : super(AppTheme.light) {
    _load();
  }

  void _load() {
    final saved = _box.get(_themeKey, defaultValue: 'light') as String;
    state = AppTheme.values.firstWhere(
      (e) => e.name == saved,
      orElse: () => AppTheme.light,
    );
  }

  Future<void> toggleTheme() async {
    final next = state == AppTheme.light ? AppTheme.dark : AppTheme.light;
    await _box.put(_themeKey, next.name);
    state = next;
  }

  bool get isDark => state == AppTheme.dark;
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppTheme>((ref) {
  return SettingsNotifier();
});

final isDarkProvider = Provider<bool>((ref) {
  return ref.watch(settingsProvider) == AppTheme.dark;
});