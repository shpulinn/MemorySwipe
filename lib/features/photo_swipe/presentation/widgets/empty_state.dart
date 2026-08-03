import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/photo_providers.dart';
import '../../../../core/services/app_router.dart';
import '../../../../core/constants/neu_constants.dart';
import '../../../trash/presentation/providers/trash_providers.dart';

class EmptyState extends ConsumerWidget {
  final Function(PhotoMode mode, {DateTime? date}) onModeSelected;
  final PhotoMode currentMode;

  const EmptyState({
    super.key,
    required this.onModeSelected,
    required this.currentMode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<int>(
      future: ref.read(trashRepositoryProvider).getTrashCount(),
      builder: (context, snapshot) {
        final trashCount = snapshot.data ?? 0;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 100, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок только для режима "сегодня"
            if (currentMode == PhotoMode.today) ...[
              Text(
                'На сегодня всё!',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Neu.text(context),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Все воспоминания этого дня просмотрены',
                style: TextStyle(
                  fontSize: 15,
                  color: Neu.textSub(context),
                ),
              ),
            ],

              // Корзина если есть фото
              if (trashCount > 0) ...[
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () => context.push(AppRouter.trash),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Neu.bg(context),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: Colors.red.withOpacity(0.4), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Neu.shadow1(context),
                          offset: const Offset(-3, -3),
                          blurRadius: 8,
                        ),
                        BoxShadow(
                          color: Neu.shadow2(context),
                          offset: const Offset(3, 3),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.delete_outline,
                              color: Colors.red, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'В корзине $trashCount фото',
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Освободи место — удали ненужное',
                                style: TextStyle(
                                  color: Colors.red.withOpacity(0.7),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right,
                            color: Colors.red.withOpacity(0.7)),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 32),
              Text(
                'Что показать?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Neu.text(context),
                ),
              ),
              const SizedBox(height: 16),

              // Кнопки режимов
              _NeuModeButton(
                icon: Icons.today,
                label: 'Воспоминания этого дня',
                isActive: currentMode == PhotoMode.today,
                onTap: () => onModeSelected(PhotoMode.today),
              ),
              const SizedBox(height: 12),
              _NeuModeButton(
                icon: Icons.access_time,
                label: 'Последние фото',
                isActive: currentMode == PhotoMode.recent,
                onTap: () => onModeSelected(PhotoMode.recent),
              ),
              const SizedBox(height: 12),
              _NeuModeButton(
                icon: Icons.screenshot,
                label: 'Скриншоты',
                isActive: currentMode == PhotoMode.screenshots,
                onTap: () => onModeSelected(PhotoMode.screenshots),
              ),
              const SizedBox(height: 12),
              _NeuModeButton(
                icon: Icons.calendar_today,
                label: 'Выбрать дату',
                isActive: false,
                onTap: () => _pickDate(context),
              ),
            ],
          ),
        );
      },
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

class _NeuModeButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NeuModeButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_NeuModeButton> createState() => _NeuModeButtonState();
}

class _NeuModeButtonState extends State<_NeuModeButton> {
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
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Neu.bg(context),
          borderRadius: BorderRadius.circular(16),
          border: widget.isActive
              ? Border.all(color: Neu.accent.withOpacity(0.5), width: 1.5)
              : null,
          boxShadow: _pressed
              ? [
                  BoxShadow(
                    color: Neu.shadow2(context),
                    offset: const Offset(-2, -2),
                    blurRadius: 5,
                  ),
                  BoxShadow(
                    color: Neu.shadow1(context),
                    offset: const Offset(2, 2),
                    blurRadius: 5,
                  ),
                ]
              : [
                  BoxShadow(
                    color: Neu.shadow1(context),
                    offset: const Offset(-4, -4),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                  BoxShadow(
                    color: Neu.shadow2(context),
                    offset: const Offset(4, 4),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: widget.isActive
                    ? Neu.accent.withOpacity(0.15)
                    : Neu.bg(context),
                shape: BoxShape.circle,
                boxShadow: widget.isActive
                    ? []
                    : [
                        BoxShadow(
                          color: Neu.shadow1(context),
                          offset: const Offset(-2, -2),
                          blurRadius: 6,
                          spreadRadius: 0,
                        ),
                        BoxShadow(
                          color: Neu.shadow2(context),
                          offset: const Offset(2, 2),
                          blurRadius: 6,
                          spreadRadius: 0,
                        ),
                      ],
              ),
              child: Icon(
                widget.icon,
                color: widget.isActive ? Neu.accent : Neu.textSub(context),
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.w400,
                color: widget.isActive ? Neu.accent : Neu.text(context),
              ),
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right,
              color: Neu.textSub(context),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}