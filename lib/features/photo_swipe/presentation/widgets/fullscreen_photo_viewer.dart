import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/photo_entity.dart';
import '../../../../core/services/share_service.dart';
import '../../../../core/constants/neu_constants.dart';

class FullscreenPhotoViewer extends StatefulWidget {
  final PhotoEntity photo;

  const FullscreenPhotoViewer({
    super.key,
    required this.photo,
  });

  static Future<void> show(BuildContext context, PhotoEntity photo) {
    return Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        pageBuilder: (context, animation, _) {
          return FadeTransition(
            opacity: animation,
            child: FullscreenPhotoViewer(photo: photo),
          );
        },
      ),
    );
  }

  @override
  State<FullscreenPhotoViewer> createState() => _FullscreenPhotoViewerState();
}

class _FullscreenPhotoViewerState extends State<FullscreenPhotoViewer> {
  final TransformationController _transformationController =
      TransformationController();
  bool _showInfo = true;
  Offset _doubleTapPosition = Offset.zero;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Фото
          GestureDetector(
            onTap: () => setState(() => _showInfo = !_showInfo),
            onDoubleTapDown: _handleDoubleTapDown,
            onDoubleTap: _handleDoubleTap,
            child: Center(
              child: InteractiveViewer(
                transformationController: _transformationController,
                minScale: 0.5,
                maxScale: 5.0,
                clipBehavior: Clip.hardEdge,
                child: Image.file(
                  File(widget.photo.path),
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.broken_image,
                    color: Colors.white54,
                    size: 64,
                  ),
                ),
              ),
            ),
          ),
          // Верхняя панель
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              ignoring: !_showInfo,
              child: AnimatedOpacity(
                opacity: _showInfo ? 1 : 0,
                duration: const Duration(milliseconds: 200),
                child: _buildTopBar(),
              ),
            ),
          ),
          // Нижняя панель
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: IgnorePointer(
              ignoring: !_showInfo,
              child: AnimatedOpacity(
                opacity: _showInfo ? 1 : 0,
                duration: const Duration(milliseconds: 200),
                child: _buildBottomBar(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.7),
            Colors.transparent,
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Row(
            children: [
              // Кнопка назад в нейморфном стиле на тёмном фоне
              _DarkNeuButton(
                icon: Icons.arrow_back,
                onTap: () => Navigator.pop(context),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _formatDate(widget.photo.createdAt),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // Кнопка поделиться
              _DarkNeuButton(
                icon: Icons.share,
                onTap: _sharePhoto,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    final photo = widget.photo;
    final sizeMb = (photo.fileSize / 1024 / 1024).toStringAsFixed(1);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withOpacity(0.8),
            Colors.transparent,
          ],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${photo.width}×${photo.height} • $sizeMb МБ',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '2x тап — сбросить зум',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleDoubleTapDown(TapDownDetails details) {
    _doubleTapPosition = details.localPosition;
  }

  void _handleDoubleTap() {
    final double currentScale =
        _transformationController.value.getMaxScaleOnAxis();

    if (currentScale > 1.1) {
      _transformationController.value = Matrix4.identity();
    } else {
      const double scale = 2.5;
      final double x = -_doubleTapPosition.dx * (scale - 1);
      final double y = -_doubleTapPosition.dy * (scale - 1);
      _transformationController.value = Matrix4.identity()
        ..translate(x, y)
        ..scale(scale);
    }
  }

  Future<void> _sharePhoto() async {
    await ShareService.sharePhoto(widget.photo.path);
  }

  String _formatDate(DateTime date) {
    final months = [
      'января', 'февраля', 'марта', 'апреля',
      'мая', 'июня', 'июля', 'августа',
      'сентября', 'октября', 'ноября', 'декабря',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

// Нейморфная кнопка для тёмного фона (полноэкранный просмотр)
class _DarkNeuButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _DarkNeuButton({
    required this.icon,
    required this.onTap,
  });

  @override
  State<_DarkNeuButton> createState() => _DarkNeuButtonState();
}

class _DarkNeuButtonState extends State<_DarkNeuButton> {
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
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF1A1B2E),
          boxShadow: _pressed
              ? const [
                  BoxShadow(
                    color: Color(0xFF0D0E1A),
                    offset: Offset(-1, -1),
                    blurRadius: 3,
                  ),
                  BoxShadow(
                    color: Color(0xFF2A2B4A),
                    offset: Offset(1, 1),
                    blurRadius: 3,
                  ),
                ]
              : const [
                  BoxShadow(
                    color: Color(0xFF2A2B4A),
                    offset: Offset(-3, -3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                  BoxShadow(
                    color: Color(0xFF0D0E1A),
                    offset: Offset(3, 3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
        ),
        child: Icon(
          widget.icon,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}