import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/neu_constants.dart';
import '../../features/settings/presentation/providers/settings_providers.dart';

class ThemeToggleSlider extends ConsumerStatefulWidget {
  const ThemeToggleSlider({super.key});

  @override
  ConsumerState<ThemeToggleSlider> createState() => _ThemeToggleSliderState();
}

class _ThemeToggleSliderState extends ConsumerState<ThemeToggleSlider>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  static const double _width = 120;
  static const double _height = 52;
  static const double _thumbSize = 44;
  static const double _thumbPadding = 4;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    // Устанавливаем начальное положение
    final isDark = ref.read(isDarkProvider);
    if (isDark) _controller.value = 1.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    final isDark = ref.read(isDarkProvider);
    if (isDark) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
    ref.read(settingsProvider.notifier).toggleTheme();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(isDarkProvider);

    return GestureDetector(
      onTap: _toggle,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Container(
            width: _width,
            height: _height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(_height / 2),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? const Color(0xFF0D0E1A)
                      : Neu.darkShadow,
                  offset: const Offset(3, 3),
                  blurRadius: 8,
                ),
                BoxShadow(
                  color: isDark
                      ? const Color(0xFF2A2B4A)
                      : Neu.lightShadow,
                  offset: const Offset(-3, -3),
                  blurRadius: 8,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(_height / 2),
              child: Stack(
                children: [
                  // Фон — день или ночь
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _ScenePainter(progress: _animation.value),
                    ),
                  ),
                  // Тумблер (круглая кнопка)
                  Positioned(
                    top: _thumbPadding,
                    left: _thumbPadding +
                        (_width - _thumbSize - _thumbPadding * 2) *
                            _animation.value,
                    child: Container(
                      width: _thumbSize,
                      height: _thumbSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark
                            ? const Color(0xFF1A1B2E)
                            : const Color(0xFF2A2B4A),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ScenePainter extends CustomPainter {
  final double progress; // 0 = день, 1 = ночь

  _ScenePainter({required this.progress});

  Color _lerpColor(Color a, Color b, double t) => Color.lerp(a, b, t)!;

  @override
  void paint(Canvas canvas, Size size) {
    // Цвета неба
    final skyTop = _lerpColor(
      const Color(0xFFFFB347),
      const Color(0xFF1A1B6E),
      progress,
    );
    final skyBottom = _lerpColor(
      const Color(0xFFFF8C69),
      const Color(0xFF2D1B69),
      progress,
    );

    // Небо
    final skyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [skyTop, skyBottom],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      skyPaint,
    );

    // Звёзды по всей площади (только ночью, слева от кружка)
    if (progress > 0.3) {
      final starOpacity = ((progress - 0.3) / 0.7).clamp(0.0, 1.0);
      final starPaint = Paint()
        ..color = Colors.white.withOpacity(starOpacity * 0.95)
        ..style = PaintingStyle.fill;

      // Звёзды равномерно по всей площади
      final stars = [
        const Offset(0.12, 0.12),
        const Offset(0.25, 0.28),
        const Offset(0.08, 0.38),
        const Offset(0.32, 0.15),
        const Offset(0.18, 0.45),
        const Offset(0.38, 0.35),
        const Offset(0.05, 0.55),
        const Offset(0.28, 0.52),
        const Offset(0.15, 0.65),
        const Offset(0.42, 0.22),
      ];

      for (final star in stars) {
        canvas.drawCircle(
          Offset(star.dx * size.width, star.dy * size.height),
          1.0,
          starPaint,
        );
      }

      // Полумесяц СЛЕВА (при ночи кружок справа — детали слева видны)
      final moonOpacity = starOpacity;
      final moonPaint = Paint()
        ..color = Colors.white.withOpacity(moonOpacity)
        ..style = PaintingStyle.fill;

      final moonX = size.width * 0.22;
      final moonY = size.height * 0.28;
      final moonR = size.height * 0.2;

      canvas.drawCircle(Offset(moonX, moonY), moonR, moonPaint);

      // Тень серпа
      final shadowPaint = Paint()
        ..color = const Color(0xFF1A1B6E).withOpacity(moonOpacity * 0.9)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(moonX + moonR * 0.35, moonY - moonR * 0.1),
        moonR * 0.85,
        shadowPaint,
      );
    }

    // Солнце СПРАВА (при дне кружок слева — солнце справа видно)
    if (progress < 0.7) {
      final sunOpacity = (1 - progress / 0.7).clamp(0.0, 1.0);
      final sunPaint = Paint()
        ..color = const Color(0xFFFFE566).withOpacity(sunOpacity)
        ..style = PaintingStyle.fill;

      final sunX = size.width * 0.82;
      final sunY = size.height * 0.28;
      final sunR = size.height * 0.18;

      // Свечение вокруг солнца
      final glowPaint = Paint()
        ..color = const Color(0xFFFFE566).withOpacity(sunOpacity * 0.3)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

      canvas.drawCircle(Offset(sunX, sunY), sunR * 1.6, glowPaint);
      canvas.drawCircle(Offset(sunX, sunY), sunR, sunPaint);
    }

    // Горы/дюны
    final duneColor = _lerpColor(
      const Color(0xFFE8845A),
      const Color(0xFF3D2B7A),
      progress,
    );

    final dunePaint = Paint()..style = PaintingStyle.fill;

    // Задние дюны
    final backDunePath = Path();
    backDunePath.moveTo(0, size.height * 0.75);
    backDunePath.quadraticBezierTo(
      size.width * 0.25, size.height * 0.45,
      size.width * 0.5, size.height * 0.6,
    );
    backDunePath.quadraticBezierTo(
      size.width * 0.75, size.height * 0.75,
      size.width, size.height * 0.65,
    );
    backDunePath.lineTo(size.width, size.height);
    backDunePath.lineTo(0, size.height);
    backDunePath.close();

    canvas.drawPath(
      backDunePath,
      dunePaint..color = duneColor.withOpacity(0.7),
    );

    // Передние дюны
    final frontDuneColor = _lerpColor(
      const Color(0xFFD4603A),
      const Color(0xFF2A1B5E),
      progress,
    );

    final frontDunePath = Path();
    frontDunePath.moveTo(0, size.height * 0.85);
    frontDunePath.quadraticBezierTo(
      size.width * 0.3, size.height * 0.6,
      size.width * 0.55, size.height * 0.75,
    );
    frontDunePath.quadraticBezierTo(
      size.width * 0.8, size.height * 0.9,
      size.width, size.height * 0.8,
    );
    frontDunePath.lineTo(size.width, size.height);
    frontDunePath.lineTo(0, size.height);
    frontDunePath.close();

    canvas.drawPath(
      frontDunePath,
      dunePaint..color = frontDuneColor,
    );
  }

  @override
  bool shouldRepaint(_ScenePainter old) => old.progress != progress;
}