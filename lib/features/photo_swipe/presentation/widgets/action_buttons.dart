import 'package:flutter/material.dart';
import '../../../../core/constants/neu_constants.dart';

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
        _NeuButton(
          onTap: onTrash,
          icon: Icons.delete_outline,
          color: const Color(0xFFE57373),
          size: 64,
        ),
        _NeuButton(
          onTap: onSkip,
          icon: Icons.arrow_upward,
          color: const Color(0xFFFFB74D),
          size: 56,
        ),
        _NeuButton(
          onTap: onKeep,
          icon: Icons.favorite_outline,
          color: const Color(0xFF81C784),
          size: 64,
        ),
      ],
    );
  }
}

class _NeuButton extends StatefulWidget {
  final VoidCallback onTap;
  final IconData icon;
  final Color color;
  final double size;

  const _NeuButton({
    required this.onTap,
    required this.icon,
    required this.color,
    required this.size,
  });

  @override
  State<_NeuButton> createState() => _NeuButtonState();
}

class _NeuButtonState extends State<_NeuButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: widget.size,
        height: widget.size,
        decoration: _pressed
            ? Neu.pressed(borderRadius: 20)
            : Neu.convex(borderRadius: 20),
        child: Icon(
          widget.icon,
          color: widget.color,
          size: widget.size * 0.45,
        ),
      ),
    );
  }
}