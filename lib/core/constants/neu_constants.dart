import 'package:flutter/material.dart';

class Neu {
  Neu._();

  // Светлая тема
  static const Color _bgLight = Color(0xFFE8EAF0);
  static const Color _lightShadowLight = Color(0xFFFFFFFF);
  static const Color _darkShadowLight = Color(0xFFC8CAD4);
  static const Color _textPrimaryLight = Color(0xFF4A4E6A);

  // Тёмная тема
  static const Color _bgDark = Color(0xFF1A1B2E);
  static const Color _lightShadowDark = Color(0xFF2A2B4A);
  static const Color _darkShadowDark = Color(0xFF0D0E1A);
  static const Color _textPrimaryDark = Color(0xFFE0E0F0);

  // Общие
  static const Color accent = Color(0xFF7B6CF6);
  static const Color textSecondary = Color(0xFF8A8FAD);

  // Статичные константы (для обратной совместимости)
  static const Color background = _bgLight;
  static const Color lightShadow = _lightShadowLight;
  static const Color darkShadow = _darkShadowLight;
  static const Color textPrimary = _textPrimaryLight;

  static const double radius = 16;
  static const double radiusLarge = 24;

  // Динамические цвета — используй где есть context
  static Color bg(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? _bgDark : _bgLight;

  static Color text(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? _textPrimaryDark
          : _textPrimaryLight;

  static Color textSub(BuildContext context) => textSecondary;

  static Color shadow1(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? _lightShadowDark
          : _lightShadowLight;

  static Color shadow2(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? _darkShadowDark
          : _darkShadowLight;

  // Динамические декорации
  static BoxDecoration convexDynamic(BuildContext context,
      {double? borderRadius}) {
    return BoxDecoration(
      color: bg(context),
      borderRadius: BorderRadius.circular(borderRadius ?? radius),
      boxShadow: [
        BoxShadow(
          color: shadow1(context),
          offset: const Offset(-4, -4),
          blurRadius: 10,
          spreadRadius: 1,
        ),
        BoxShadow(
          color: shadow2(context),
          offset: const Offset(4, 4),
          blurRadius: 10,
          spreadRadius: 1,
        ),
      ],
    );
  }

  static BoxDecoration pressedDynamic(BuildContext context,
      {double? borderRadius}) {
    return BoxDecoration(
      color: bg(context),
      borderRadius: BorderRadius.circular(borderRadius ?? radius),
      boxShadow: [
        BoxShadow(
          color: shadow2(context),
          offset: const Offset(-1, -1),
          blurRadius: 3,
        ),
        BoxShadow(
          color: shadow1(context),
          offset: const Offset(1, 1),
          blurRadius: 3,
        ),
      ],
    );
  }

  // Статичные декорации (для обратной совместимости)
  static BoxDecoration convex({double? borderRadius}) {
    return BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(borderRadius ?? radius),
      boxShadow: const [
        BoxShadow(
          color: lightShadow,
          offset: Offset(-4, -4),
          blurRadius: 10,
          spreadRadius: 1,
        ),
        BoxShadow(
          color: darkShadow,
          offset: Offset(4, 4),
          blurRadius: 10,
          spreadRadius: 1,
        ),
      ],
    );
  }

  static BoxDecoration concave({double? borderRadius}) {
    return BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(borderRadius ?? radius),
      boxShadow: const [
        BoxShadow(
          color: darkShadow,
          offset: Offset(-2, -2),
          blurRadius: 5,
          spreadRadius: 1,
        ),
        BoxShadow(
          color: lightShadow,
          offset: Offset(2, 2),
          blurRadius: 5,
          spreadRadius: 1,
        ),
      ],
    );
  }

  static BoxDecoration pressed({double? borderRadius}) {
    return BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(borderRadius ?? radius),
      boxShadow: const [
        BoxShadow(
          color: darkShadow,
          offset: Offset(-1, -1),
          blurRadius: 3,
          spreadRadius: 0,
        ),
        BoxShadow(
          color: lightShadow,
          offset: Offset(1, 1),
          blurRadius: 3,
          spreadRadius: 0,
        ),
      ],
    );
  }
}