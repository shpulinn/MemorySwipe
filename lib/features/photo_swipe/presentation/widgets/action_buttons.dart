import 'dart:ui';
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
        _GlassButton(
          onTap: onTrash,
          icon: Icons.delete_outline,
          color: Colors.red,
          size: 64,
        ),
        _GlassButton(
          onTap: onSkip,
          icon: Icons.arrow_upward,
          color: Colors.orange,
          size: 56,
        ),
        _GlassButton(
          onTap: onKeep,
          icon: Icons.favorite_outline,
          color: Colors.green,
          size: 64,
        ),
      ],
    );
  }
}

class _GlassButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final Color color;
  final double size;

  const _GlassButton({
    required this.onTap,
    required this.icon,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.white.withOpacity(0.6),
              border: Border.all(
                color: color.withOpacity(0.5),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: color,
              size: size * 0.45,
            ),
          ),
        ),
      ),
    );
  }
}