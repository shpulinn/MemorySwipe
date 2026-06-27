import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/app_router.dart';
import 'package:go_router/go_router.dart';

class OnboardingIntroScreen extends StatefulWidget {
  const OnboardingIntroScreen({super.key});

  @override
  State<OnboardingIntroScreen> createState() => _OnboardingIntroScreenState();
}

class _OnboardingIntroScreenState extends State<OnboardingIntroScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const List<_OnboardingPage> _pages = [
    _OnboardingPage(
      icon: Icons.photo_library_outlined,
      title: 'Привет!',
      description:
          'Memory Swipe показывает фотографии, сделанные в этот день в прошлые годы.\n\nВспомни что происходило год, два, три назад и сохрани самые лучшие моменты в своей памяти.',
      color: Colors.deepPurple,
    ),
    _OnboardingPage(
      icon: Icons.swipe,
      title: 'Свайпай фото',
      description:
          '👉 Вправо — оставить фото\n\n👈 Влево — отправить в корзину\n\n👆 Вверх — пропустить и показать позже',
      color: Colors.blue,
    ),
    _OnboardingPage(
      icon: Icons.zoom_in,
      title: 'Нажми, чтобы увидеть больше',
      description:
          'Нажми на фото, чтобы открыть его на весь экран.\n\nТакже, в этом режиме можно приблизить фото и быстро поделиться им с друзьями.',
      color: Colors.amber,
    ),
    _OnboardingPage(
      icon: Icons.delete_outline,
      title: 'Безопасная корзина',
      description:
          'Фото не удаляются сразу.\n\nОни попадают в корзину приложения, откуда ты можешь их восстановить или удалить навсегда.',
      color: Colors.green,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Кнопка пропустить
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _finish,
                child: Text(
                  'Пропустить',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ),
            ),
            // Слайды
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),
            // Индикаторы страниц
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => _buildDot(index),
              ),
            ),
            const SizedBox(height: 32),
            // Кнопка далее / начать
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _pages[_currentPage].color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    _currentPage == _pages.length - 1
                        ? 'Начать'
                        : 'Далее',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(_OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Иконка
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: page.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: page.color.withOpacity(0.4),
                width: 2,
              ),
            ),
            child: Icon(
              page.icon,
              color: page.color,
              size: 60,
            ),
          ),
          const SizedBox(height: 40),
          // Заголовок
          Text(
            page.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          // Описание
          Text(
            page.description,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 16,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    final bool isActive = index == _currentPage;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive
            ? _pages[_currentPage].color
            : Colors.grey[700],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    // Сохраняем что онбординг показан
    final box = Hive.box<dynamic>(AppConstants.settingsBoxName);
    await box.put(AppConstants.onboardingShownKey, true);

    if (mounted) {
      context.go(AppRouter.onboarding);
    }
  }
}

// Модель слайда
class _OnboardingPage {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}