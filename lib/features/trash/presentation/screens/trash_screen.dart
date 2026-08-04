import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/trash_providers.dart';
import '../../domain/entities/trash_item_entity.dart';
import '../../../../core/constants/neu_constants.dart';
import '../../../statistics/presentation/providers/statistics_providers.dart';
import '../../../photo_swipe/presentation/providers/photo_providers.dart';

class TrashScreen extends ConsumerStatefulWidget {
  const TrashScreen({super.key});

  @override
  ConsumerState<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends ConsumerState<TrashScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(trashNotifierProvider.notifier).loadItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(trashNotifierProvider);

    return Scaffold(
      backgroundColor: Neu.bg(context),
      appBar: AppBar(
        backgroundColor: Neu.bg(context),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Neu.text(context)),
        title: Text(
          state.hasSelection
              ? 'Выбрано: ${state.selectedIds.length}'
              : 'Корзина',
          style: TextStyle(
            color: Neu.text(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (state.hasSelection) ...[
            IconButton(
              icon: Icon(Icons.restore, color: Neu.text(context)),
              tooltip: 'Восстановить',
              onPressed: () => _restoreSelected(state),
            ),
            IconButton(
              icon: const Icon(Icons.delete_forever, color: Colors.red),
              tooltip: 'Удалить навсегда',
              onPressed: () => _confirmDeleteSelected(state),
            ),
          ] else if (state.items.isNotEmpty) ...[
            IconButton(
              icon: Icon(Icons.delete_sweep, color: Neu.text(context)),
              tooltip: 'Очистить корзину',
              onPressed: () => _confirmClearAll(),
            ),
          ],
        ],
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(TrashState state) {
    if (state.isLoading) {
      return Center(
        child: CircularProgressIndicator(color: Neu.accent),
      );
    }

    if (state.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            state.error!,
            style: TextStyle(color: Neu.text(context)),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (state.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Neu.bg(context),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Neu.shadow1(context),
                    offset: const Offset(-4, -4),
                    blurRadius: 10,
                  ),
                  BoxShadow(
                    color: Neu.shadow2(context),
                    offset: const Offset(4, 4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Icon(
                Icons.delete_outline,
                size: 56,
                color: Neu.textSub(context),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Корзина пуста',
              style: TextStyle(
                color: Neu.text(context),
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Фото помеченные на удаление появятся здесь',
              style: TextStyle(color: Neu.textSub(context), fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildSizeInfo(state),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: state.items.length,
            itemBuilder: (context, index) {
              return _buildTrashItem(state.items[index], state);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSizeInfo(TrashState state) {
    final sizeMb = (state.totalSize / 1024 / 1024).toStringAsFixed(1);
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Neu.bg(context),
        borderRadius: BorderRadius.circular(16),
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
          Icon(Icons.info_outline, color: Neu.textSub(context), size: 16),
          const SizedBox(width: 8),
          Text(
            '${state.items.length} фото • $sizeMb МБ',
            style: TextStyle(color: Neu.textSub(context), fontSize: 14),
          ),
          const Spacer(),
          Text(
            'Удерживай для выбора',
            style: TextStyle(color: Neu.textSub(context), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildTrashItem(TrashItemEntity item, TrashState state) {
    final isSelected = state.selectedIds.contains(item.photoId);

    return GestureDetector(
      onTap: () {
        if (state.hasSelection) {
          ref.read(trashNotifierProvider.notifier).toggleSelection(item.photoId);
        } else {
          _showItemOptions(item);
        }
      },
      onLongPress: () {
        ref.read(trashNotifierProvider.notifier).toggleSelection(item.photoId);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Neu.shadow1(context),
              offset: const Offset(-2, -2),
              blurRadius: 6,
            ),
            BoxShadow(
              color: Neu.shadow2(context),
              offset: const Offset(2, 2),
              blurRadius: 6,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.file(
                File(item.photoPath),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Neu.bg(context),
                  child: Icon(
                    Icons.broken_image,
                    color: Neu.textSub(context),
                  ),
                ),
              ),
              if (isSelected)
                Container(
                  decoration: BoxDecoration(
                    color: Neu.accent.withOpacity(0.6),
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Text(
                    _formatDate(item.originalDate),
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showItemOptions(TrashItemEntity item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Neu.bg(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Neu.textSub(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(item.photoPath),
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.broken_image,
                    color: Neu.textSub(context),
                    size: 64,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _formatDate(item.originalDate),
              style: TextStyle(
                color: Neu.textSub(context),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.restore, color: Colors.green),
              title: Text(
                'Восстановить',
                style: TextStyle(color: Neu.text(context)),
              ),
              onTap: () {
                Navigator.pop(context);
                ref.read(trashNotifierProvider.notifier).restore(item.photoId);
                ref.read(statisticsNotifierProvider.notifier)
                    .undoTrashed(fileSize: item.fileSize);
                ref.read(photoSwipeProvider.notifier)
                    .removeFromHistory(item.photoId);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text(
                'Удалить навсегда',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                _confirmDeleteOne(item);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeleteOne(TrashItemEntity item) async {
    final confirm = await _showConfirmDialog(
      title: 'Удалить фото?',
      message: 'Фото будет удалено навсегда. Это действие нельзя отменить.',
      confirmLabel: 'Удалить',
    );
    if (confirm == true) {
      final success = await ref
          .read(trashNotifierProvider.notifier)
          .deletePermanently(item.photoId);
      if (!success && mounted) _showDeletionError();
    }
  }

  Future<void> _confirmDeleteSelected(TrashState state) async {
    final confirm = await _showConfirmDialog(
      title: 'Удалить ${state.selectedIds.length} фото?',
      message: 'Фото будут удалены навсегда. Это действие нельзя отменить.',
      confirmLabel: 'Удалить',
    );
    if (confirm == true) {
      await ref.read(trashNotifierProvider.notifier).deleteSelected();
      if (mounted) {
        final remaining = ref.read(trashNotifierProvider).items;
        if (remaining.isNotEmpty) _showDeletionError();
      }
    }
  }

  Future<void> _confirmClearAll() async {
    final confirm = await _showConfirmDialog(
      title: 'Очистить корзину?',
      message: 'Все фото будут удалены навсегда. Это действие нельзя отменить.',
      confirmLabel: 'Очистить',
    );
    if (confirm == true) {
      ref.read(trashNotifierProvider.notifier).clearAll();
    }
  }

  Future<void> _restoreSelected(TrashState state) async {
    final items = state.items
        .where((i) => state.selectedIds.contains(i.photoId))
        .toList();

    for (final item in items) {
      await ref.read(trashNotifierProvider.notifier).restore(item.photoId);
      ref.read(statisticsNotifierProvider.notifier)
          .undoTrashed(fileSize: item.fileSize);
      ref.read(photoSwipeProvider.notifier)
          .removeFromHistory(item.photoId);
    }
  }

  Future<bool?> _showConfirmDialog({
    required String title,
    required String message,
    required String confirmLabel,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              confirmLabel,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'янв', 'фев', 'мар', 'апр', 'май', 'июн',
      'июл', 'авг', 'сен', 'окт', 'ноя', 'дек',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _showDeletionError() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Не удалось удалить'),
        content: const Text(
          'Ваше устройство или прошивка ограничивают удаление фото сторонними приложениями.\n\nФото можно удалить вручную через системную галерею.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Понятно'),
          ),
        ],
      ),
    );
  }
}