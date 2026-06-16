import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/constants/app_constants.dart';
import 'core/services/app_router.dart';

void main() async {
  // Убеждаемся что Flutter готов к работе
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализируем локальную базу данных
  await Hive.initFlutter();

  // Открываем все нужные "таблицы" базы данных
  await Hive.openBox<bool>(AppConstants.viewedPhotosBoxName);
  await Hive.openBox<String>(AppConstants.trashBoxName);
  await Hive.openBox<dynamic>(AppConstants.settingsBoxName);
  await Hive.openBox<dynamic>(AppConstants.statisticsBoxName);

  runApp(
    // ProviderScope — обязательная обёртка для Riverpod
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