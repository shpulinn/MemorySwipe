import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_providers.dart';
import '../../../statistics/presentation/providers/statistics_providers.dart';
import '../../../photo_swipe/presentation/providers/photo_providers.dart';
import '../../../../core/constants/neu_constants.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Neu.bg(context),
      appBar: AppBar(
        backgroundColor: Neu.bg(context),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Neu.text(context)),
        title: Text(
          'Настройки',
          style: TextStyle(
            color: Neu.text(context),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader(context, 'Данные'),
          const SizedBox(height: 8),
          _buildNeuTile(
            context: context,
            icon: Icons.refresh,
            iconColor: Neu.accent,
            title: 'Показать просмотренные фото снова',
            subtitle: 'Сбросит список просмотренных фото',
            onTap: () => _confirmResetViewed(context, ref),
          ),
          const SizedBox(height: 12),
          _buildNeuTile(
            context: context,
            icon: Icons.bar_chart_outlined,
            iconColor: Colors.blue,
            title: 'Сбросить статистику',
            subtitle: 'Обнулит все счётчики',
            onTap: () => _confirmResetStats(context, ref),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(context, 'О приложении'),
          const SizedBox(height: 8),
          _buildNeuTile(
            context: context,
            icon: Icons.info_outline,
            iconColor: Neu.textSecondary,
            title: 'Memory Swipe',
            subtitle: 'Версия 1.0.1',
            onTap: null,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          color: Neu.accent,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildNeuTile({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Neu.bg(context),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Neu.shadow1(context),
              offset: const Offset(-4, -4),
              blurRadius: 10,
              spreadRadius: 1,
            ),
            BoxShadow(
              color: Neu.shadow2(context),
              offset: const Offset(4, 4),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Neu.bg(context),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Neu.shadow2(context),
                    offset: const Offset(-2, -2),
                    blurRadius: 5,
                  ),
                  BoxShadow(
                    color: Neu.shadow1(context),
                    offset: const Offset(2, 2),
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Neu.text(context),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Neu.textSub(context),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.chevron_right,
                color: Neu.textSub(context),
                size: 20,
              ),
          ],
        ),
      ),
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