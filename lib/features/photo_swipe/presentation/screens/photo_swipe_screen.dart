import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memory_swipe/features/photo_swipe/domain/entities/photo_entity.dart';
import 'package:memory_swipe/features/photo_swipe/presentation/providers/photo_providers.dart';
import 'package:memory_swipe/features/photo_swipe/presentation/widgets/action_buttons.dart';
import 'package:memory_swipe/features/photo_swipe/presentation/widgets/empty_state.dart';
import 'package:memory_swipe/features/photo_swipe/presentation/widgets/swipe_indicator.dart';
import 'package:memory_swipe/features/photo_swipe/presentation/widgets/swipeable_card_stack.dart';
import '../../../../core/services/app_router.dart';
import '../../../trash/presentation/providers/trash_providers.dart';
import '../../../trash/domain/entities/trash_item_entity.dart';
import '../widgets/fullscreen_photo_viewer.dart';
import '../../../statistics/presentation/providers/statistics_providers.dart';

class PhotoSwipeScreen extends ConsumerStatefulWidget {
  const PhotoSwipeScreen({super.key});

  @override
  ConsumerState<PhotoSwipeScreen> createState() => _PhotoSwipeScreenState();
}

class _PhotoSwipeScreenState extends ConsumerState<PhotoSwipeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref.read(photoSwipeProvider.notifier).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(photoSwipeProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Memory Swipe',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          // Кнопка статистики
          IconButton(
            icon: const Icon(Icons.bar_chart, color: Colors.white),
            onPressed: () => context.push(AppRouter.statistics),
          ),
          // Кнопка корзины
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            onPressed: () => context.push(AppRouter.trash),
          ),
          // Кнопка настроек
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () => context.push(AppRouter.settings),
          ),
        ],
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(PhotoSwipeState state) {
    // Нет разрешения на доступ к галерее
    if (!state.hasPermission && !state.isLoading) {
      return _buildPermissionDenied();
    }

    // Загрузка
    if (state.isLoading && state.photos.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.deepPurple),
      );
    }

    // Ошибка
    if (state.error != null && state.photos.isEmpty) {
      return _buildError(state.error!);
    }

    // Фото закончились
    if (state.photos.isEmpty) {
      return EmptyState(
        onModeSelected: (mode, {date}) {
          ref.read(photoSwipeProvider.notifier).changeMode(mode, date: date);
        },
      );
    }

    // Основной контент
    return Column(
      children: [
        // Счётчик фото
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            _buildCounterText(state),
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
        ),
        // Стек карточек
        Expanded(
          child: Center(
            child: SwipeableCardStack(
              photos: state.photos,
              onLoadMore: () {
                ref.read(photoSwipeProvider.notifier).loadMore();
              },
              onSwiped: (photo, direction) {
                _handleSwipe(photo, direction);
              },
              onTap: (photo) {
                _openFullScreen(photo);
              },
            ),
          ),
        ),
        // Кнопки действий
        // Кнопки действий — SafeArea защищает от системной панели
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: ActionButtons(
              onTrash: () {
                if (state.photos.isNotEmpty) {
                  _handleSwipe(state.photos.first, SwipeDirection.left);
                }
              },
              onSkip: () {
                if (state.photos.isNotEmpty) {
                  _handleSwipe(state.photos.first, SwipeDirection.up);
                }
              },
              onKeep: () {
                if (state.photos.isNotEmpty) {
                  _handleSwipe(state.photos.first, SwipeDirection.right);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  void _handleSwipe(PhotoEntity photo, SwipeDirection direction) {
    final notifier = ref.read(photoSwipeProvider.notifier);
    final stats = ref.read(statisticsNotifierProvider.notifier);

    switch (direction) {
      case SwipeDirection.left:
        ref.read(addToTrashProvider).call(
          TrashItemEntity(
            photoId: photo.id,
            photoPath: photo.path,
            originalDate: photo.createdAt,
            deletedAt: DateTime.now(),
            fileSize: photo.fileSize,
          ),
        );
        stats.recordTrashed(fileSize: photo.fileSize);
        notifier.removePhoto(photo.id);
        break;
      case SwipeDirection.right:
        stats.recordKept();
        notifier.removePhoto(photo.id);
        break;
      case SwipeDirection.up:
        stats.recordSkipped();
        notifier.skipPhoto(photo.id);
        break;
    }
  }

  void _openFullScreen(PhotoEntity photo) {
    FullscreenPhotoViewer.show(context, photo);
  }

  String _buildCounterText(PhotoSwipeState state) {
    final now = DateTime.now();
    switch (state.mode) {
      case PhotoMode.today:
        return 'Воспоминания • ${now.day} ${_monthName(now.month)}';
      case PhotoMode.recent:
        return 'Последние фото';
      case PhotoMode.screenshots:
        return 'Скриншоты';
      case PhotoMode.byDate:
        if (state.selectedDate != null) {
          final d = state.selectedDate!;
          return '${d.day} ${_monthName(d.month)} ${d.year}';
        }
        return 'Фото по дате';
    }
  }

  String _monthName(int month) {
    const months = [
      'января', 'февраля', 'марта', 'апреля',
      'мая', 'июня', 'июля', 'августа',
      'сентября', 'октября', 'ноября', 'декабря',
    ];
    return months[month - 1];
  }

  Widget _buildPermissionDenied() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.photo_library_outlined,
                size: 80, color: Colors.grey),
            const SizedBox(height: 24),
            const Text(
              'Нет доступа к фото',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Разреши доступ к галерее в настройках телефона',
              style: TextStyle(fontSize: 16, color: Colors.grey[400]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                ref.read(photoSwipeProvider.notifier).initialize();
              },
              child: const Text('Попробовать снова'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            error,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              ref.read(photoSwipeProvider.notifier).initialize();
            },
            child: const Text('Повторить'),
          ),
        ],
      ),
    );
  }
}