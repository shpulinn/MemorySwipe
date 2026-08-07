import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';

class ShareService {
  ShareService._();

  // Системный шаринг
  static Future<void> sharePhoto(String photoPath) async {
    final file = File(photoPath);
    if (!await file.exists()) return;

    final xFile = XFile(photoPath);
    await Share.shareXFiles(
      [xFile],
      text: 'Memory Swipe',
    );
  }

  // Шаринг в Telegram
  static Future<bool> shareToTelegram(String photoPath) async {
    final file = File(photoPath);
    if (!await file.exists()) return false;

    try {
      final xFile = XFile(photoPath);
      final result = await Share.shareXFiles(
        [xFile],
        sharePositionOrigin: Rect.zero,
      );
      // Пробуем открыть напрямую через Telegram
      return await _shareToApp(
        photoPath: photoPath,
        packageName: 'org.telegram.messenger',
      );
    } catch (e) {
      return false;
    }
  }

  // Шаринг во ВКонтакте
  static Future<bool> shareToVK(String photoPath) async {
    return await _shareToApp(
      photoPath: photoPath,
      packageName: 'com.vkontakte.android',
    );
  }

  // Универсальный метод шаринга в конкретное приложение
  static Future<bool> _shareToApp({
    required String photoPath,
    required String packageName,
  }) async {
    final file = File(photoPath);
    if (!await file.exists()) return false;

    try {
      final xFile = XFile(photoPath);
      await Share.shareXFiles([xFile]);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Проверить установлено ли приложение
  static Future<bool> isAppInstalled(String packageName) async {
    try {
      const platform = MethodChannel('app_checker');
      final bool result = await platform.invokeMethod(
        'isInstalled',
        {'package': packageName},
      );
      return result;
    } catch (e) {
      // Если канал недоступен — считаем что приложение есть
      return true;
    }
  }
}