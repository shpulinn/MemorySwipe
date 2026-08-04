import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/statistics_providers.dart';
import '../../../../core/constants/neu_constants.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statisticsNotifierProvider);

    return Scaffold(
      backgroundColor: Neu.bg(context),
      appBar: AppBar(
        backgroundColor: Neu.bg(context),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Статистика',
          style: TextStyle(
            color: Neu.text(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: IconThemeData(color: Neu.text(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Главная карточка — освобождено места
            _buildHighlightCard(
              context: context,
              icon: Icons.storage,
              label: 'Освобождено места',
              value: '${stats.freedMb.toStringAsFixed(1)} МБ',
              color: Neu.accent,
            ),
            const SizedBox(height: 16),

            // Сетка
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
        color: Neu.bg(context),
        borderRadius: BorderRadius.circular(20),
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
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Neu.bg(context),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Neu.shadow2(context),
                  offset: const Offset(-2, -2),
                  blurRadius: 6,
                ),
                BoxShadow(
                  color: Neu.shadow1(context),
                  offset: const Offset(2, 2),
                  blurRadius: 6,
                ),
              ],
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
                  color: Neu.textSub(context),
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
        color: Neu.bg(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Neu.shadow1(context),
            offset: const Offset(-3, -3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Neu.shadow2(context),
            offset: const Offset(3, 3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Иконка вдавленная
          Container(
            padding: const EdgeInsets.all(8),
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
            child: Icon(icon, color: color, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: Neu.text(context),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: Neu.textSub(context),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}