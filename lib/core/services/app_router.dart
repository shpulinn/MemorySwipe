import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memory_swipe/features/onboarding/presentation/screens/photo_swipe_screen.dart';
import 'package:memory_swipe/features/onboarding/presentation/screens/settings_screen.dart';
import 'package:memory_swipe/features/onboarding/presentation/screens/statistics_screen.dart';
import 'package:memory_swipe/features/onboarding/presentation/screens/trash_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';

class AppRouter {
  AppRouter._();

  static const String onboarding = '/onboarding';
  static const String photoSwipe = '/';
  static const String trash = '/trash';
  static const String statistics = '/statistics';
  static const String settings = '/settings';

  static final GoRouter router = GoRouter(
    initialLocation: photoSwipe,
    routes: [
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