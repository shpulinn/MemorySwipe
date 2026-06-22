import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/photo_entity.dart';

class FullscreenPhotoViewer extends StatefulWidget {
  final PhotoEntity photo;

  const FullscreenPhotoViewer({
    super.key,
    required this.photo,
  });

  // Удобный метод для открытия
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
  // Контроллер для зума
  final TransformationController _transformationController =
      TransformationController();

  // Показывать ли панель с информацией
  bool _showInfo = true;

  @override
  void initState() {
    super.initState();
    // Скрываем системные панели для полноэкранного режима
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    // Возвращаем системные панели
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
          GestureDetector(
            onTap: () => setState(() => _showInfo = !_showInfo),
            onDoubleTap: _resetZoom,
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
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                color: Colors.white,
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 8),
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
              IconButton(
                icon: const Icon(Icons.share),
                color: Colors.white,
                onPressed: _sharePhoto,
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

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
  }

  Future<void> _sharePhoto() async {
    // Покажем снэкбар — поделиться добавим на следующем шаге
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Функция "Поделиться" — скоро')),
    );
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