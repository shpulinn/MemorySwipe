import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/constants/app_constants.dart';
import 'core/services/app_router.dart';
import 'features/settings/presentation/providers/settings_providers.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Hive.initFlutter();
  await Hive.openBox<bool>(AppConstants.viewedPhotosBoxName);
  await Hive.openBox<String>(AppConstants.trashBoxName);
  await Hive.openBox<dynamic>(AppConstants.settingsBoxName);
  await Hive.openBox<dynamic>(AppConstants.statisticsBoxName);

  FlutterNativeSplash.remove();

  runApp(
    const ProviderScope(
      child: MemorySwipeApp(),
    ),
  );
}

class MemorySwipeApp extends ConsumerWidget {
  const MemorySwipeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(isDarkProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7B6CF6),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFE8EAF0),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFE8EAF0),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7B6CF6),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF1A1B2E),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A1B2E),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      routerConfig: AppRouter.router,
    );
  }
}