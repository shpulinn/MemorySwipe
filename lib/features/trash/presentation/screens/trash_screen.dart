import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/trash_providers.dart';
import '../../domain/entities/trash_item_entity.dart';

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
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: state.hasSelection
            ? Text('Выбрано: ${state.selectedIds.length}')
            : const Text('Корзина'),
        actions: [
          if (state.hasSelection) ...[
            // Восстановить выбранные
            IconButton(
              icon: const Icon(Icons.restore),
              tooltip: 'Восстановить',
              onPressed: () => _restoreSelected(state),
            ),
            // Удалить выбранные
            IconButton(
              icon: const Icon(Icons.delete_forever, color: Colors.red),
              tooltip: 'Удалить навсегда',
              onPressed: () => _confirmDeleteSelected(state),
            ),
          ] else if (state.items.isNotEmpty) ...[
            // Очистить всю корзину
            IconButton(
              icon: const Icon(Icons.delete_sweep),
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
      return const Center(
        child: CircularProgressIndicator(color: Colors.deepPurple),
      );
    }

    if (state.error != null) {
      return Center(
        child: Text(
          state.error!,
          style: const TextStyle(color: Colors.white),
        ),
      );
    }

    if (state.items.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Корзина пуста',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            SizedBox(height: 8),
            Text(
              'Фото помеченные на удаление появятся здесь',
              style: TextStyle(color: Colors.grey, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Информация об объёме
        _buildSizeInfo(state),
        // Сетка фото
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.grey[900],
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.grey, size: 16),
          const SizedBox(width: 8),
          Text(
            '${state.items.length} фото • $sizeMb МБ',
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const Spacer(),
          Text(
            'Удерживай для выбора',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
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
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Фото
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.file(
              File(item.photoPath),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey[800],
                child: const Icon(Icons.broken_image, color: Colors.white54),
              ),
            ),
          ),
          // Затемнение если выбрано
          if (isSelected)
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Colors.deepPurple.withOpacity(0.6),
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 32,
              ),
            ),
          // Дата удаления
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(4),
                ),
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
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showItemOptions(TrashItemEntity item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            // Превью фото
            SizedBox(
              height: 200,
              child: Image.file(
                File(item.photoPath),
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.broken_image,
                  color: Colors.white54,
                  size: 64,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _formatDate(item.originalDate),
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 20),
            // Восстановить
            ListTile(
              leading: const Icon(Icons.restore, color: Colors.green),
              title: const Text(
                'Восстановить',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                ref.read(trashNotifierProvider.notifier).restore(item.photoId);
              },
            ),
            // Удалить навсегда
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
      if (!success && mounted) {
        _showDeletionError();
      }
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
        if (remaining.isNotEmpty) {
          _showDeletionError();
        }
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
    for (final id in state.selectedIds.toList()) {
      await ref.read(trashNotifierProvider.notifier).restore(id);
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
        backgroundColor: Colors.grey[900],
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: Text(message, style: const TextStyle(color: Colors.grey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const TextStyle(color: Colors.white) == null
                ? const Text('Отмена')
                : const Text(
                    'Отмена',
                    style: TextStyle(color: Colors.white),
                  ),
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
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Не удалось удалить',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Ваше устройство или прошивка ограничивают удаление фото сторонними приложениями.\n\nФото можно удалить вручную через системную галерею.',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Понятно',
              style: TextStyle(color: Colors.deepPurple),
            ),
          ),
        ],
      ),
    );
  }
}