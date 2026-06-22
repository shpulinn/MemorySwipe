import 'dart:io';
import 'package:share_plus/share_plus.dart';

class ShareService {
  ShareService._();

  static Future<void> sharePhoto(String photoPath) async {
    final file = File(photoPath);
    if (!await file.exists()) return;

    final xFile = XFile(photoPath);
    await Share.shareXFiles(
      [xFile],
      text: 'Memory Swipe',
    );
  }
}