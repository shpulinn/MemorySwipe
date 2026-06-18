import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/constants/app_constants.dart';
import 'core/services/app_router.dart';

void main() async {
  // Сохраняем сплэш пока идёт инициализация
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Инициализируем базу данных
  await Hive.initFlutter();
  await Hive.openBox<bool>(AppConstants.viewedPhotosBoxName);
  await Hive.openBox<String>(AppConstants.trashBoxName);
  await Hive.openBox<dynamic>(AppConstants.settingsBoxName);
  await Hive.openBox<dynamic>(AppConstants.statisticsBoxName);

  // Убираем сплэш — всё готово
  FlutterNativeSplash.remove();

  runApp(
    const ProviderScope(
      child: MemorySwipeApp(),
    ),
  );
}

class MemorySwipeApp extends StatelessWidget {
  const MemorySwipeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      routerConfig: AppRouter.router,
    );
  }
}