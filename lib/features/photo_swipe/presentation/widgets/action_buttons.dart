import 'dart:ui';
import 'package:flutter/material.dart';

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
          color: const Color(0xFFE57373),
          size: 64,
        ),
        _GlassButton(
          onTap: onSkip,
          icon: Icons.arrow_upward,
          color: const Color(0xFFFFB74D),
          size: 64,
        ),
        _GlassButton(
          onTap: onKeep,
          icon: Icons.favorite_outline,
          color: const Color(0xFF81C784),
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

    // Непрозрачность зависит от темы
    final fillOpacity = isDark ? 0.45 : 0.75;
    final borderOpacity = isDark ? 0.4 : 0.6;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            // Основная тень — строго под кнопкой
            BoxShadow(
              color: color.withOpacity(isDark ? 0.5 : 0.4),
              blurRadius: 10,
              spreadRadius: -2, // отрицательный spread — тень не выходит наружу
              offset: const Offset(0, 5),
            ),
            // Глубокая тень для объёма
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.15),
              blurRadius: 8,
              spreadRadius: -3,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                // Основная заливка
                color: color.withOpacity(fillOpacity),
                border: Border.all(
                  color: Colors.white.withOpacity(borderOpacity),
                  width: 1.5,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: const [0.0, 0.4, 1.0],
                  colors: [
                    // Яркий блик в верхнем левом углу
                    Colors.white.withOpacity(isDark ? 0.4 : 0.6),
                    // Основной цвет в середине
                    color.withOpacity(fillOpacity),
                    // Чуть темнее внизу для объёма
                    color.withOpacity(isDark ? 0.6 : 0.85),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Блик — полоска сверху
                  Positioned(
                    top: 0,
                    left: 4,
                    right: 4,
                    child: Container(
                      height: size * 0.25,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(18),
                          topRight: Radius.circular(18),
                          bottomLeft: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withOpacity(isDark ? 0.25 : 0.4),
                            Colors.white.withOpacity(0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Иконка по центру
                  Center(
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: size * 0.45,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}