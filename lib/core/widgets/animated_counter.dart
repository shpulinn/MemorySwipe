import 'package:flutter/material.dart';

class AnimatedCounter extends StatefulWidget {
  final int value;
  final TextStyle style;
  final Duration duration;

  const AnimatedCounter({
    super.key,
    required this.value,
    required this.style,
    this.duration = const Duration(milliseconds: 600),
  });

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late int _oldValue;
  late int _newValue;

  @override
  void initState() {
    super.initState();
    _oldValue = widget.value;
    _newValue = widget.value;

    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void didUpdateWidget(AnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _oldValue = oldWidget.value;
      _newValue = widget.value;
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        // Интерполируем значение
        final displayValue = (_oldValue +
                (_newValue - _oldValue) * _animation.value)
            .round();

        return ClipRect(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Уходящее число (уезжает вверх)
              if (_controller.isAnimating)
                Transform.translate(
                  offset: Offset(0, -30 * _animation.value),
                  child: Opacity(
                    opacity: (1 - _animation.value).clamp(0.0, 1.0),
                    child: Text(
                      _formatValue(_oldValue),
                      style: widget.style,
                    ),
                  ),
                ),
              // Новое число (приезжает снизу)
              Transform.translate(
                offset: Offset(
                    0, 30 * (1 - _animation.value).clamp(0.0, 1.0)),
                child: Opacity(
                  opacity: _animation.value.clamp(0.0, 1.0),
                  child: Text(
                    _formatValue(displayValue),
                    style: widget.style,
                  ),
                ),
              ),
              // Статичное число когда анимация не идёт
              if (!_controller.isAnimating)
                Text(
                  _formatValue(_newValue),
                  style: widget.style,
                ),
            ],
          ),
        );
      },
    );
  }

  String _formatValue(int value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return '$value';
  }
}

// Специальный виджет для МБ с анимацией
class AnimatedMbCounter extends StatefulWidget {
  final double value;
  final TextStyle style;
  final Duration duration;

  const AnimatedMbCounter({
    super.key,
    required this.value,
    required this.style,
    this.duration = const Duration(milliseconds: 800),
  });

  @override
  State<AnimatedMbCounter> createState() => _AnimatedMbCounterState();
}

class _AnimatedMbCounterState extends State<AnimatedMbCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late double _oldValue;
  late double _newValue;

  @override
  void initState() {
    super.initState();
    _oldValue = widget.value;
    _newValue = widget.value;

    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void didUpdateWidget(AnimatedMbCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _oldValue = oldWidget.value;
      _newValue = widget.value;
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final displayValue =
            _oldValue + (_newValue - _oldValue) * _animation.value;

        return Text(
          '${displayValue.toStringAsFixed(1)} МБ',
          style: widget.style,
        );
      },
    );
  }
}