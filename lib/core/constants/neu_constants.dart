import 'package:flutter/material.dart';

class Neu {
  Neu._();

  // Основной цвет фона
  static const Color background = Color(0xFFE8EAF0);

  // Светлая тень (верхний левый угол)
  static const Color lightShadow = Color(0xFFFFFFFF);

  // Тёмная тень (нижний правый угол)
  static const Color darkShadow = Color(0xFFC8CAD4);

  // Цвет текста
  static const Color textPrimary = Color(0xFF4A4E6A);
  static const Color textSecondary = Color(0xFF8A8FAD);

  // Акцентный цвет
  static const Color accent = Color(0xFF7B6CF6);

  // Радиус скругления
  static const double radius = 16;
  static const double radiusLarge = 24;

  // Декорация для выпуклого элемента (кнопки, карточки)
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

  // Декорация для вдавленного элемента (поля ввода, индикаторы)
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

  // Декорация для нажатой кнопки
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