import 'package:flutter/material.dart';
import '../../domain/entities/photo_entity.dart';
import 'photo_card.dart';
import 'swipe_indicator.dart';

class SwipeableCardStack extends StatefulWidget {
  final List<PhotoEntity> photos;
  final VoidCallback? onLoadMore;
  final Function(PhotoEntity photo, SwipeDirection direction) onSwiped;
  final Function(PhotoEntity photo) onTap;

  const SwipeableCardStack({
    super.key,
    required this.photos,
    required this.onSwiped,
    required this.onTap,
    this.onLoadMore,
  });

  @override
  State<SwipeableCardStack> createState() => _SwipeableCardStackState();
}

class _SwipeableCardStackState extends State<SwipeableCardStack>
    with SingleTickerProviderStateMixin {
  // Смещение карточки при перетаскивании
  Offset _dragOffset = Offset.zero;
  // Угол поворота карточки
  double _rotation = 0;

  // Порог после которого считается свайп (в пикселях)
  static const double _swipeThreshold = 100;
  // Порог для свайпа вверх
  static const double _upSwipeThreshold = -80;

  @override
  Widget build(BuildContext context) {
    if (widget.photos.isEmpty) {
      return const SizedBox.shrink();
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        // Фоновые карточки (следующие в очереди)
        if (widget.photos.length > 2)
          _buildBackCard(widget.photos[2], scale: 0.88, offsetY: -20),
        if (widget.photos.length > 1)
          _buildBackCard(widget.photos[1], scale: 0.94, offsetY: -10),
        // Главная карточка (та что сейчас)
        _buildFrontCard(widget.photos[0]),
      ],
    );
  }

  // Фоновая карточка (неинтерактивная)
  Widget _buildBackCard(PhotoEntity photo, {
    required double scale,
    required double offsetY,
  }) {
    return Transform.translate(
      offset: Offset(0, offsetY),
      child: Transform.scale(
        scale: scale,
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.85,
          height: MediaQuery.of(context).size.height * 0.6,
          child: PhotoCard(photo: photo),
        ),
      ),
    );
  }

  // Главная карточка (интерактивная)
  Widget _buildFrontCard(PhotoEntity photo) {
    // Вычисляем прозрачность индикаторов
    final horizontalProgress = _dragOffset.dx / _swipeThreshold;
    final upProgress = _dragOffset.dy / _upSwipeThreshold;

    return GestureDetector(
      onPanStart: (_) => setState(() {}),
      onPanUpdate: (details) {
        setState(() {
          _dragOffset += details.delta;
          // Карточка слегка поворачивается при перетаскивании
          _rotation = _dragOffset.dx * 0.002;
        });
      },
      onPanEnd: (_) => _handleDragEnd(photo),
      child: Transform.translate(
        offset: _dragOffset,
        child: Transform.rotate(
          angle: _rotation,
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.85,
            height: MediaQuery.of(context).size.height * 0.6,
            child: Stack(
              children: [
                PhotoCard(
                  photo: photo,
                  onTap: () => widget.onTap(photo),
                ),
                // Индикатор "ОСТАВИТЬ" (свайп вправо)
                if (_dragOffset.dx > 0)
                  Positioned(
                    top: 40,
                    left: 20,
                    child: SwipeIndicator(
                      direction: SwipeDirection.right,
                      opacity: horizontalProgress,
                    ),
                  ),
                // Индикатор "В КОРЗИНУ" (свайп влево)
                if (_dragOffset.dx < 0)
                  Positioned(
                    top: 40,
                    right: 20,
                    child: SwipeIndicator(
                      direction: SwipeDirection.left,
                      opacity: -horizontalProgress,
                    ),
                  ),
                // Индикатор "ПОЗЖЕ" (свайп вверх)
                if (_dragOffset.dy < 0)
                  Positioned(
                    bottom: 40,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: SwipeIndicator(
                        direction: SwipeDirection.up,
                        opacity: upProgress,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleDragEnd(PhotoEntity photo) {
    // Определяем в какую сторону свайпнули
    if (_dragOffset.dx > _swipeThreshold) {
      _completeSwipe(photo, SwipeDirection.right);
    } else if (_dragOffset.dx < -_swipeThreshold) {
      _completeSwipe(photo, SwipeDirection.left);
    } else if (_dragOffset.dy < _upSwipeThreshold) {
      _completeSwipe(photo, SwipeDirection.up);
    } else {
      // Не дотянули — возвращаем карточку на место
      setState(() {
        _dragOffset = Offset.zero;
        _rotation = 0;
      });
    }
  }

  void _completeSwipe(PhotoEntity photo, SwipeDirection direction) {
    setState(() {
      _dragOffset = Offset.zero;
      _rotation = 0;
    });

    widget.onSwiped(photo, direction);

    // Подгружаем следующие фото когда карточек мало
    if (widget.photos.length <= 3) {
      widget.onLoadMore?.call();
    }
  }
}