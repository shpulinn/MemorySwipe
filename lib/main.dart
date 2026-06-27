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
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      // Тёмная тема
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: Colors.black,
        useMaterial3: true,
      ),
      // Светлая тема
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      routerConfig: AppRouter.router,
    );
  }
}