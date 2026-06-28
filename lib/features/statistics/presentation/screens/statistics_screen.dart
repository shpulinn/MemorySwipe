import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/statistics_providers.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statisticsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Статистика'),
        actions: [
          // Кнопка сброса
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Сбросить',
            onPressed: () => _confirmReset(context, ref),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок
            Text(
              'Ваши достижения',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Статистика за всё время',
              style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              fontSize: 14,
            ),
            ),
            const SizedBox(height: 32),

            // Карточка освобождённого места
            _buildHighlightCard(
              context: context,
              icon: Icons.storage,
              label: 'Освобождено места',
              value: '${stats.freedMb.toStringAsFixed(1)} МБ',
              color: Colors.deepPurple,
            ),
            const SizedBox(height: 16),

            // Сетка с остальной статистикой
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.4,
              children: [
                _buildStatCard(
                  context: context,
                  icon: Icons.remove_red_eye_outlined,
                  label: 'Просмотрено',
                  value: '${stats.totalViewed}',
                  color: Colors.blue,
                ),
                _buildStatCard(
                  context: context,
                  icon: Icons.delete_outline,
                  label: 'В корзину',
                  value: '${stats.totalTrashed}',
                  color: Colors.red,
                ),
                _buildStatCard(
                  context: context,
                  icon: Icons.favorite_outline,
                  label: 'Оставлено',
                  value: '${stats.totalKept}',
                  color: Colors.green,
                ),
                _buildStatCard(
                  context: context,
                  icon: Icons.arrow_upward,
                  label: 'Пропущено',
                  value: '${stats.totalSkipped}',
                  color: Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Подсказка
            Center(
              child: Text(
                'Свайпай фото чтобы видеть прогресс здесь',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Сбросить статистику?'),
        content: const Text('Все данные статистики будут удалены.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Сбросить',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      ref.read(statisticsNotifierProvider.notifier).reset();
    }
  }
}