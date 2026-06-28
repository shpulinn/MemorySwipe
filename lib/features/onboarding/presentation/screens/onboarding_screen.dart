import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../photo_swipe/presentation/providers/photo_providers.dart';
import '../../../../core/services/app_router.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Случайная фраза выбирается один раз при открытии экрана
  late final String _phrase;

  static const List<String> _phrases = [
    'Твои воспоминания ждут',
    'Прошлое хранит лучшие моменты',
    'Освободи место для новых фото',
    'Каждое фото — это история',
    'Путешествие в прошлое начинается',
    'Что ты фотографировал год назад?',
    'Воспоминания важнее гигабайт',
    'Сохрани лучшее, отпусти остальное',
    'Твой телефон помнит всё',
    'Загляни в прошлое на минуту',
  ];

  @override
  void initState() {
    super.initState();

    // Выбираем случайную фразу
    _phrase = _phrases[Random().nextInt(_phrases.length)];

    // Анимация появления
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();

    // Запрашиваем разрешение и загружаем фото
    Future.microtask(() async {
      await ref.read(photoSwipeProvider.notifier).initialize();
      if (mounted) {
        context.go(AppRouter.photoSwipe);
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Иконка приложения
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.deepPurple.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.photo_library_outlined,
                    color: Colors.deepPurple,
                    size: 52,
                  ),
                ),
                const SizedBox(height: 32),
                // Название
                const Text(
                  'Memory Swipe',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 16),
                // Случайная фраза
                Text(
                  _phrase,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                    ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 60),
                // Индикатор загрузки
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.deepPurple.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}