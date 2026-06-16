import 'package:flutter/material.dart';
import 'swipe_indicator.dart';

class ActionButtons extends StatelessWidget {
  final VoidCallback onTrash;
  final VoidCallback onSkip;
  final VoidCallback onKeep;

  const ActionButtons({
    super.key,
    required this.onTrash,
    required this.onSkip,
    required this.onKeep,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Корзина (свайп влево)
        _ActionButton(
          onTap: onTrash,
          icon: Icons.delete_outline,
          color: Colors.red,
          size: 56,
        ),
        // Пропустить (свайп вверх)
        _ActionButton(
          onTap: onSkip,
          icon: Icons.arrow_upward,
          color: Colors.orange,
          size: 48,
        ),
        // Оставить (свайп вправо)
        _ActionButton(
          onTap: onKeep,
          icon: Icons.favorite_outline,
          color: Colors.green,
          size: 56,
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final Color color;
  final double size;

  const _ActionButton({
    required this.onTap,
    required this.icon,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey[900],
          border: Border.all(color: color, width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: color,
          size: size * 0.5,
        ),
      ),
    );
  }
}