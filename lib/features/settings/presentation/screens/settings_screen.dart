import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_providers.dart';
import '../../../statistics/presentation/providers/statistics_providers.dart';
import '../../../photo_swipe/presentation/providers/photo_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
      ),
      body: ListView(
        children: [
          // Раздел — Внешний вид
          _buildSectionHeader(context, 'Внешний вид'),
          _buildThemeTile(context, ref, currentTheme, AppTheme.dark, '🌙 Тёмный'),
          _buildThemeTile(context, ref, currentTheme, AppTheme.light, '☀️ Светлый'),
          _buildThemeTile(context, ref, currentTheme, AppTheme.system, '📱 Системный'),

          const Divider(),

          // Раздел — Данные
          _buildSectionHeader(context, 'Данные'),
          ListTile(
            leading: const Icon(Icons.refresh),
            title: const Text('Показать просмотренные фото снова'),
            subtitle: const Text('Сбросит список просмотренных фото'),
            onTap: () => _confirmResetViewed(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart_outlined),
            title: const Text('Сбросить статистику'),
            subtitle: const Text('Обнулит все счётчики'),
            onTap: () => _confirmResetStats(context, ref),
          ),

          const Divider(),

          // Раздел — О приложении
          _buildSectionHeader(context, 'О приложении'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Memory Swipe'),
            subtitle: const Text('Версия 1.0.0'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildThemeTile(
    BuildContext context,
    WidgetRef ref,
    AppTheme current,
    AppTheme value,
    String label,
  ) {
    return RadioListTile<AppTheme>(
      title: Text(label),
      value: value,
      groupValue: current,
      onChanged: (theme) {
        if (theme != null) {
          ref.read(settingsProvider.notifier).setTheme(theme);
        }
      },
    );
  }

  Future<void> _confirmResetViewed(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Сбросить просмотренные?'),
        content: const Text(
          'Все фото будут показаны снова в режиме "В этот день".',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Сбросить'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // Сбрасываем просмотренные фото
      ref.read(photoSwipeProvider.notifier).resetViewed();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Просмотренные фото сброшены')),
        );
      }
    }
  }

  Future<void> _confirmResetStats(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Сбросить статистику?'),
        content: const Text('Все счётчики обнулятся.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Сбросить'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      ref.read(statisticsNotifierProvider.notifier).reset();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Статистика сброшена')),
        );
      }
    }
  }
}