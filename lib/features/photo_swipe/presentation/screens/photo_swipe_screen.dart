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
import 'package:app_settings/app_settings.dart';
import '../../../../core/constants/neu_constants.dart';
import '../../../../core/widgets/theme_toggle_slider.dart';

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

  final GlobalKey<SwipeableCardStackState> _cardStackKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(photoSwipeProvider);

    final isMenuScreen = state.photos.isEmpty && !state.isLoading;

    return Scaffold(
      backgroundColor: Neu.bg(context),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Контент — занимает весь экран включая зону AppBar
          Positioned.fill(
            child: _buildBody(state),
          ),
          // AppBar — поверх контента по умолчанию
          // но карточка при перетаскивании будет поверх него
          // потому что Stack рисует последние элементы поверх
          // а карточка рендерится внутри body через Transform
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Container(
                  height: 64,
                  decoration: Neu.convexDynamic(context, borderRadius: 32),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      if (isMenuScreen)
                        const ThemeToggleSlider()
                      else
                        _NeuCircleButton(
                          icon: Icons.grid_view_rounded,
                          onTap: () => _confirmGoToMenu(),
                        ),
                      const Spacer(),
                      if (state.canUndo && state.photos.isNotEmpty)
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            _NeuCircleButton(
                              icon: Icons.undo,
                              onTap: () async {
                                final last = state.lastAction!;
                                final stats = ref.read(statisticsNotifierProvider.notifier);
                                switch (last.direction) {
                                  case SwipeDirection.left:
                                    ref.read(trashRepositoryProvider).restoreFromTrash(last.photo.id);
                                    stats.undoTrashed(fileSize: last.photo.fileSize);
                                    break;
                                  case SwipeDirection.right:
                                    stats.undoKept();
                                    break;
                                  case SwipeDirection.up:
                                    stats.undoSkipped();
                                    break;
                                }
                                ref.read(photoSwipeProvider.notifier).undoLastAction();
                              },
                              onLongPress: () async {
                                final history = List<LastAction>.from(state.actionHistory);
                                for (final action in history.reversed) {
                                  final stats = ref.read(statisticsNotifierProvider.notifier);
                                  switch (action.direction) {
                                    case SwipeDirection.left:
                                      ref.read(trashRepositoryProvider).restoreFromTrash(action.photo.id);
                                      stats.undoTrashed(fileSize: action.photo.fileSize);
                                      break;
                                    case SwipeDirection.right:
                                      stats.undoKept();
                                      break;
                                    case SwipeDirection.up:
                                      stats.undoSkipped();
                                      break;
                                  }
                                }
                                await ref.read(photoSwipeProvider.notifier).undoAll();
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Отменено ${history.length} действий'),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                }
                              },
                            ),
                            if (state.actionHistory.length > 1)
                              Positioned(
                                right: 2,
                                top: 2,
                                child: Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: Neu.accent,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${state.actionHistory.length}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      const SizedBox(width: 8),
                      _NeuCircleButton(
                        icon: Icons.bar_chart,
                        onTap: () => context.push(AppRouter.statistics),
                      ),
                      const SizedBox(width: 8),
                      _NeuCircleButton(
                        icon: Icons.delete_outline,
                        onTap: () => context.push(AppRouter.trash),
                      ),
                      const SizedBox(width: 8),
                      _NeuCircleButton(
                        icon: Icons.settings_outlined,
                        onTap: () => context.push(AppRouter.settings),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
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
      return _EmptyStateWithCelebration(
        mode: state.mode,
        onModeSelected: (mode, {date}) {
          ref.read(photoSwipeProvider.notifier).changeMode(mode, date: date);
        },
      );
    }

    // Основной контент
    return Column(
      children: [
        // Отступ под AppBar
        const SizedBox(height: 80),
        // Счётчик фото
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          // child: Text(
          //   _buildCounterText(state),
          //   style: TextStyle(
          //     color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          //     fontSize: 14,
          //   ),
          // ),
        ),
        // Стек карточек
        Expanded(
          child: Center(
            child: SwipeableCardStack(
                key: _cardStackKey,
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
                _cardStackKey.currentState?.triggerSwipe(SwipeDirection.left);
              }
            },
            onSkip: () {
              if (state.photos.isNotEmpty) {
                _cardStackKey.currentState?.triggerSwipe(SwipeDirection.up);
              }
            },
            onKeep: () {
              if (state.photos.isNotEmpty) {
                _cardStackKey.currentState?.triggerSwipe(SwipeDirection.right);
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
        notifier.removePhoto(photo.id, direction: direction);
        break;
      case SwipeDirection.right:
        stats.recordKept();
        notifier.removePhoto(photo.id, direction: direction);
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
            const Icon(
              Icons.photo_library_outlined,
              size: 80,
              color: Colors.grey,
            ),
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
              'Чтобы приложение работало, нужно разрешить доступ к фотографиям.',
              style: TextStyle(fontSize: 16, color: Colors.grey[400]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // Кнопка открытия настроек
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await AppSettings.openAppSettings();
                },
                icon: const Icon(Icons.settings),
                label: const Text('Открыть настройки'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Кнопка повторной проверки
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  ref.read(photoSwipeProvider.notifier).initialize();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Я уже разрешил — проверить'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.grey),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[800]!),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.grey[500],
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'После выдачи разрешения может потребоваться перезапуск приложения',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
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
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 16,
            ),
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

  Future<void> _confirmGoToMenu() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выйти в меню?'),
        content: const Text(
          'Текущий прогресс будет сохранён.\nВы сможете вернуться к просмотру позже.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Выйти'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      // Показываем экран "На сегодня всё" который и есть главное меню
      ref.read(photoSwipeProvider.notifier).clearPhotos();
    }
  }

  Widget _buildModeSheet(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Что показать?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 20),
            _SheetButton(
              icon: Icons.today,
              label: 'Воспоминания этого дня',
              onTap: () {
                Navigator.pop(context);
                ref
                    .read(photoSwipeProvider.notifier)
                    .changeMode(PhotoMode.today);
              },
            ),
            const SizedBox(height: 12),
            _SheetButton(
              icon: Icons.access_time,
              label: 'Последние фото',
              onTap: () {
                Navigator.pop(context);
                ref
                    .read(photoSwipeProvider.notifier)
                    .changeMode(PhotoMode.recent);
              },
            ),
            const SizedBox(height: 12),
            _SheetButton(
              icon: Icons.screenshot,
              label: 'Скриншоты',
              onTap: () {
                Navigator.pop(context);
                ref
                    .read(photoSwipeProvider.notifier)
                    .changeMode(PhotoMode.screenshots);
              },
            ),
            const SizedBox(height: 12),
            _SheetButton(
              icon: Icons.calendar_today,
              label: 'Выбрать дату',
              onTap: () async {
                Navigator.pop(context);
                final date = await showDatePicker(
                  context: context,
                  initialDate:
                      DateTime.now().subtract(const Duration(days: 365)),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (date != null && mounted) {
                  ref
                      .read(photoSwipeProvider.notifier)
                      .changeMode(PhotoMode.byDate, date: date);
                }
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _SheetButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SheetButton({
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
          side: BorderSide(color: Theme.of(context).colorScheme.outline),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

class _EmptyStateWithCelebration extends ConsumerWidget {
  final PhotoMode mode;
  final Function(PhotoMode mode, {DateTime? date}) onModeSelected;

  const _EmptyStateWithCelebration({
    required this.mode,
    required this.onModeSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return EmptyState(
      currentMode: mode,
      onModeSelected: onModeSelected,
    );
  }
}

class _NeuCircleButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _NeuCircleButton({
    required this.icon,
    required this.onTap,
    this.onLongPress,
  });

  @override
  State<_NeuCircleButton> createState() => _NeuCircleButtonState();
}

class _NeuCircleButtonState extends State<_NeuCircleButton> {
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
      onLongPress: widget.onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Neu.bg(context),
          boxShadow: _pressed
              ? [
                  BoxShadow(
                    color: Neu.shadow2(context),
                    offset: const Offset(-1, -1),
                    blurRadius: 3,
                  ),
                  BoxShadow(
                    color: Neu.shadow1(context),
                    offset: const Offset(1, 1),
                    blurRadius: 3,
                  ),
                ]
              : [
                  BoxShadow(
                    color: Neu.shadow1(context),
                    offset: const Offset(-3, -3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                  BoxShadow(
                    color: Neu.shadow2(context),
                    offset: const Offset(3, 3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
        ),
        child: Icon(
          widget.icon,
          color: Neu.text(context),
          size: 20,
        ),
      ),
    );
  }
}