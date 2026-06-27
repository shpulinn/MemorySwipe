import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_intro_screen.dart';
import '../../features/photo_swipe/presentation/screens/photo_swipe_screen.dart';
import '../../features/trash/presentation/screens/trash_screen.dart';
import '../../features/statistics/presentation/screens/statistics_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../constants/app_constants.dart';

class AppRouter {
  AppRouter._();

  static const String onboardingIntro = '/onboarding-intro';
  static const String onboarding = '/onboarding';
  static const String photoSwipe = '/';
  static const String trash = '/trash';
  static const String statistics = '/statistics';
  static const String settings = '/settings';

  static bool _isOnboardingShown() {
    final box = Hive.box<dynamic>(AppConstants.settingsBoxName);
    return box.get(AppConstants.onboardingShownKey, defaultValue: false) as bool;
  }

  static final GoRouter router = GoRouter(
    initialLocation: photoSwipe,
    redirect: (context, state) {
      // Если онбординг ещё не показывался и мы не на экране онбординга
      if (!_isOnboardingShown() &&
          state.matchedLocation != onboardingIntro) {
        return onboardingIntro;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: onboardingIntro,
        builder: (context, state) => const OnboardingIntroScreen(),
      ),
      GoRoute(
        path: onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: photoSwipe,
        builder: (context, state) => const PhotoSwipeScreen(),
      ),
      GoRoute(
        path: trash,
        builder: (context, state) => const TrashScreen(),
      ),
      GoRoute(
        path: statistics,
        builder: (context, state) => const StatisticsScreen(),
      ),
      GoRoute(
        path: settings,
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
}