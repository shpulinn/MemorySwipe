import 'package:flutter/material.dart';

enum SwipeDirection { left, right, up }

class SwipeIndicator extends StatelessWidget {
  final SwipeDirection direction;
  final double opacity;

  const SwipeIndicator({
    super.key,
    required this.direction,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity.clamp(0.0, 1.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: _color, width: 3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          _label,
          style: TextStyle(
            color: _color,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }

  Color get _color {
    switch (direction) {
      case SwipeDirection.left:
        return Colors.red;
      case SwipeDirection.right:
        return Colors.green;
      case SwipeDirection.up:
        return Colors.orange;
    }
  }

  String get _label {
    switch (direction) {
      case SwipeDirection.left:
        return 'В КОРЗИНУ';
      case SwipeDirection.right:
        return 'ОСТАВИТЬ';
      case SwipeDirection.up:
        return 'ПОЗЖЕ';
    }
  }
}