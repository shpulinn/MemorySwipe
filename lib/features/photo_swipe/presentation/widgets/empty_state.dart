import 'package:flutter/material.dart';
import '../providers/photo_providers.dart';

class EmptyState extends StatelessWidget {
  final Function(PhotoMode mode, {DateTime? date}) onModeSelected;

  const EmptyState({
    super.key,
    required this.onModeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_awesome,
            size: 80,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            'На сегодня всё!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Все воспоминания этого дня просмотрены',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          Text(
            'Что показать дальше?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 24),
          _ModeButton(
            icon: Icons.access_time,
            label: 'Последние фото',
            onTap: () => onModeSelected(PhotoMode.recent),
          ),
          const SizedBox(height: 12),
          _ModeButton(
            icon: Icons.screenshot,
            label: 'Скриншоты',
            onTap: () => onModeSelected(PhotoMode.screenshots),
          ),
          const SizedBox(height: 12),
          _ModeButton(
            icon: Icons.calendar_today,
            label: 'Выбрать дату',
            onTap: () => _pickDate(context),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365)),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      onModeSelected(PhotoMode.byDate, date: date);
    }
  }
}

class _ModeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ModeButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          side: BorderSide(
            color: Theme.of(context).colorScheme.outline,
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}