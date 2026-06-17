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
    with TickerProviderStateMixin {
  Offset _dragOffset = Offset.zero;
  double _rotation = 0;

  // Контроллер для анимации вылета
  late AnimationController _flyController;
  late Animation<Offset> _flyAnimation;

  // Контроллер для анимации возврата
  late AnimationController _returnController;
  late Animation<Offset> _returnAnimation;
  late Animation<double> _returnRotation;

  bool _isAnimating = false;
  bool _isReturning = false;
  SwipeDirection? _lastDirection;

  static const double _swipeThreshold = 100;
  static const double _upSwipeThreshold = -80;

  @override
  void initState() {
    super.initState();

    _flyController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _onFlyComplete();
        }
      });

    _returnController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _isReturning = false;
            _dragOffset = Offset.zero;
            _rotation = 0;
            _returnController.reset();
          });
        }
      });
  }

  @override
  void dispose() {
    _flyController.dispose();
    _returnController.dispose();
    super.dispose();
  }

  void _onFlyComplete() {
    if (!mounted) return;

    final photo = widget.photos.first;
    final direction = _lastDirection!;

    // Сразу убираем карточку из списка — не сбрасывая offset
    widget.onSwiped(photo, direction);
    if (widget.photos.length <= 5) {
      widget.onLoadMore?.call();
    }

    // Сбрасываем состояние только после следующего кадра
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _isAnimating = false;
          _lastDirection = null;
          _dragOffset = Offset.zero;
          _rotation = 0;
          _flyController.reset();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.photos.isEmpty) return const SizedBox.shrink();

    return Stack(
      alignment: Alignment.center,
      children: [
        if (widget.photos.length > 2)
          _buildBackCard(widget.photos[2], scale: 0.88, offsetY: -20),
        if (widget.photos.length > 1)
          _buildBackCard(widget.photos[1], scale: 0.94, offsetY: -10),
        _buildFrontCard(widget.photos[0]),
      ],
    );
  }

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
          child: PhotoCard(photo: photo, showDate: false),
        ),
      ),
    );
  }

  Widget _buildFrontCard(PhotoEntity photo) {
    Color glowColor = Colors.transparent;
    double glowOpacity = 0;

    if (!_isAnimating && !_isReturning) {
      final horizontalProgress = _dragOffset.dx / _swipeThreshold;
      final upProgress = _dragOffset.dy / _upSwipeThreshold;

      if (_dragOffset.dx > 20) {
        glowColor = Colors.green;
        glowOpacity = horizontalProgress.clamp(0.0, 1.0);
      } else if (_dragOffset.dx < -20) {
        glowColor = Colors.red;
        glowOpacity = (-horizontalProgress).clamp(0.0, 1.0);
      } else if (_dragOffset.dy < -20) {
        glowColor = Colors.orange;
        glowOpacity = upProgress.clamp(0.0, 1.0);
      }
    }

    return AnimatedBuilder(
      animation: Listenable.merge([_flyController, _returnController]),
      builder: (context, child) {
        Offset currentOffset;
        double currentRotation;

        if (_isAnimating) {
          currentOffset = _flyAnimation.value;
          currentRotation = _rotation * (1 - _flyController.value * 0.5);
        } else if (_isReturning) {
          currentOffset = _returnAnimation.value;
          currentRotation = _returnRotation.value;
        } else {
          currentOffset = _dragOffset;
          currentRotation = _rotation;
        }

        return GestureDetector(
          onPanStart: (_isAnimating || _isReturning) ? null : (_) => setState(() {}),
          onPanUpdate: (_isAnimating || _isReturning)
              ? null
              : (details) {
                  setState(() {
                    _dragOffset += details.delta;
                    _rotation = _dragOffset.dx * 0.002;
                  });
                },
          onPanEnd: (_isAnimating || _isReturning)
              ? null
              : (_) => _handleDragEnd(photo),
           child: Visibility(
          // Скрываем карточку пока идёт сброс после анимации
          visible: !(_flyController.status == AnimationStatus.completed),
          child: Transform.translate(
            offset: currentOffset,
            child: Transform.rotate(
              angle: currentRotation,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.85,
                height: MediaQuery.of(context).size.height * 0.6,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: glowOpacity > 0.1
                        ? [
                            BoxShadow(
                              color: glowColor.withOpacity(glowOpacity * 0.9),
                              blurRadius: 60,
                              spreadRadius: 10,
                            ),
                          ]
                        : [],
                  ),
                  child: Stack(
                    children: [
                      PhotoCard(
                        photo: photo,
                        onTap: () => widget.onTap(photo),
                      ),
                      if (glowOpacity > 0.1)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: glowColor.withOpacity(glowOpacity),
                                width: 4,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
           ),
        );
      },
    );
  }

  void _handleDragEnd(PhotoEntity photo) {
    if (_dragOffset.dx > _swipeThreshold) {
      _startFlyAnimation(SwipeDirection.right);
    } else if (_dragOffset.dx < -_swipeThreshold) {
      _startFlyAnimation(SwipeDirection.left);
    } else if (_dragOffset.dy < _upSwipeThreshold) {
      _startFlyAnimation(SwipeDirection.up);
    } else {
      _startReturnAnimation();
    }
  }

  void _startReturnAnimation() {
    _returnAnimation = Tween<Offset>(
      begin: _dragOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _returnController,
      curve: Curves.elasticOut,
    ));

    _returnRotation = Tween<double>(
      begin: _rotation,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _returnController,
      curve: Curves.elasticOut,
    ));

    setState(() => _isReturning = true);
    _returnController.forward(from: 0);
  }

  void _startFlyAnimation(SwipeDirection direction) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    Offset targetOffset;
    switch (direction) {
      case SwipeDirection.left:
        targetOffset = Offset(-screenWidth * 1.8, _dragOffset.dy + 50);
        break;
      case SwipeDirection.right:
        targetOffset = Offset(screenWidth * 1.8, _dragOffset.dy + 50);
        break;
      case SwipeDirection.up:
        targetOffset = Offset(_dragOffset.dx, -screenHeight * 1.5);
        break;
    }

    _flyAnimation = Tween<Offset>(
      begin: _dragOffset,
      end: targetOffset,
    ).animate(CurvedAnimation(
      parent: _flyController,
      curve: Curves.easeIn,
    ));

    setState(() {
      _isAnimating = true;
      _lastDirection = direction;
    });

    _flyController.forward(from: 0);
  }
}