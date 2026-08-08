import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/statistics_providers.dart';
import '../../../../core/constants/neu_constants.dart';

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      body: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHighlightCard(
                  icon: Icons.storage,
                  label: 'Освобождено места',
                  value: '${stats.freedMb.toStringAsFixed(1)} МБ',
                  color: Neu.accent,
                ),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.4,
                  children: [
                    _buildStatCard(
                      icon: Icons.remove_red_eye_outlined,
                      label: 'Просмотрено',
                      value: '${stats.totalViewed}',
                      color: Colors.blue,
                    ),
                    _buildStatCard(
                      icon: Icons.delete_outline,
                      label: 'В корзину',
                      value: '${stats.totalTrashed}',
                      color: Colors.red,
                    ),
                    _buildStatCard(
                      icon: Icons.favorite_outline,
                      label: 'Оставлено',
                      value: '${stats.totalKept}',
                      color: Colors.green,
                    ),
                    _buildStatCard(
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
        ),
      ),
    );
  }

  Widget _buildHighlightCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return _AnimatedCard(
      delay: 0,
      child: Container(
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
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return _AnimatedCard(
      delay: 100,
      child: Container(
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
      ),
    );
  }
}

// Карточка с анимацией появления снизу
class _AnimatedCard extends StatefulWidget {
  final Widget child;
  final int delay;

  const _AnimatedCard({required this.child, required this.delay});

  @override
  State<_AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<_AnimatedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: widget.child,
      ),
    );
  }
}