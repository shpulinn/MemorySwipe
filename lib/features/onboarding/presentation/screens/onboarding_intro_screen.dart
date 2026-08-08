import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/neu_constants.dart';
import '../../../../core/services/app_router.dart';
import 'package:go_router/go_router.dart';

class OnboardingIntroScreen extends StatefulWidget {
  const OnboardingIntroScreen({super.key});

  @override
  State<OnboardingIntroScreen> createState() => _OnboardingIntroScreenState();
}

class _OnboardingIntroScreenState extends State<OnboardingIntroScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _iconController;
  late Animation<double> _iconScale;
  late Animation<double> _iconFade;

  static const List<_OnboardingPage> _pages = [
    _OnboardingPage(
      icon: Icons.photo_library_outlined,
      title: 'Привет!',
      description:
          'Memory Swipe показывает фотографии, сделанные в этот день в прошлые годы.\n\nВспомни, что происходило год, два, три назад.',
      color: Color.fromRGBO(203, 170, 213, 1),
    ),
    _OnboardingPage(
      icon: Icons.swipe,
      title: 'Свайпай фото',
      description:
          '👉 Вправо — оставить фото\n\n👈 Влево — отправить в корзину\n\n👆 Вверх — пропустить и показать позже',
      color: Color.fromRGBO(255, 221, 149, 1),
    ),
    _OnboardingPage(
      icon: Icons.zoom_in,
      title: 'Рассмотри детально',
      description:
          'Нажми на фото, чтобы открыть его на весь экран.\n\nМожно приблизить и быстро поделиться с друзьями.',
      color: Color.fromRGBO(205, 230, 164, 1),
    ),
    _OnboardingPage(
      icon: Icons.delete_outline,
      title: 'Безопасная корзина',
      description:
          'Фото не удаляются сразу.\n\nОни попадают в корзину, откуда можно восстановить или удалить навсегда.',
      color: Color.fromRGBO(132, 227, 200, 1),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _iconController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _iconScale = CurvedAnimation(
      parent: _iconController,
      curve: Curves.elasticOut,
    );
    _iconFade = CurvedAnimation(
      parent: _iconController,
      curve: Curves.easeIn,
    );
    _iconController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
    _iconController.reset();
    _iconController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final currentColor = _pages[_currentPage].color;

    return Scaffold(
      backgroundColor: Neu.background,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Neu.background,
              currentColor.withOpacity(0.15),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Кнопка пропустить
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: TextButton(
                    onPressed: _finish,
                    child: Text(
                      'Пропустить',
                      style: TextStyle(color: Neu.textSecondary),
                    ),
                  ),
                ),
              ),
              // Слайды
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: _onPageChanged,
                  itemBuilder: (context, index) {
                    return _buildPage(_pages[index]);
                  },
                ),
              ),
              // Индикаторы
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
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Neu.lightShadow,
                          offset: const Offset(-3, -3),
                          blurRadius: 8,
                        ),
                        BoxShadow(
                          color: currentColor.withOpacity(0.4),
                          offset: const Offset(3, 3),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: currentColor,
                        foregroundColor: Neu.textPrimary,
                        elevation: 0,
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
              ),
              const SizedBox(height: 32),
            ],
          ),
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
          // Иконка с анимацией
          ScaleTransition(
            scale: _iconScale,
            child: FadeTransition(
              opacity: _iconFade,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  color: Neu.background,
                  borderRadius: BorderRadius.circular(36),
                  boxShadow: [
                    BoxShadow(
                      color: Neu.lightShadow,
                      offset: const Offset(-6, -6),
                      blurRadius: 14,
                      spreadRadius: 1,
                    ),
                    BoxShadow(
                      color: page.color.withOpacity(0.5),
                      offset: const Offset(6, 6),
                      blurRadius: 14,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Icon(
                  page.icon,
                  color: page.color,
                  size: 64,
                ),
              ),
            ),
          ),
          const SizedBox(height: 44),
          // Заголовок
          Text(
            page.title,
            style: TextStyle(
              color: Neu.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          // Описание
          Text(
            page.description,
            style: TextStyle(
              color: Neu.textSecondary,
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
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? _pages[_currentPage].color : Neu.darkShadow,
        borderRadius: BorderRadius.circular(4),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: _pages[_currentPage].color.withOpacity(0.4),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
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
    final box = Hive.box<dynamic>(AppConstants.settingsBoxName);
    await box.put(AppConstants.onboardingShownKey, true);

    if (mounted) {
      context.go(AppRouter.onboarding);
    }
  }
}

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