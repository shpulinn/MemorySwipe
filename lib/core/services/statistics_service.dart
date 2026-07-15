import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_constants.dart';
import '../../features/statistics/domain/entities/statistics_entity.dart';

class StatisticsService {
  Box<dynamic> get _box => Hive.box<dynamic>(AppConstants.statisticsBoxName);

  static const String _viewedKey = 'total_viewed';
  static const String _trashedKey = 'total_trashed';
  static const String _keptKey = 'total_kept';
  static const String _skippedKey = 'total_skipped';
  static const String _freedBytesKey = 'freed_bytes';

  // Получить текущую статистику
  StatisticsEntity getStatistics() {
    return StatisticsEntity(
      totalViewed: _box.get(_viewedKey, defaultValue: 0) as int,
      totalTrashed: _box.get(_trashedKey, defaultValue: 0) as int,
      totalKept: _box.get(_keptKey, defaultValue: 0) as int,
      totalSkipped: _box.get(_skippedKey, defaultValue: 0) as int,
      freedBytes: _box.get(_freedBytesKey, defaultValue: 0) as int,
    );
  }

  // Записать просмотр
  Future<void> recordViewed() async {
    final current = _box.get(_viewedKey, defaultValue: 0) as int;
    await _box.put(_viewedKey, current + 1);
  }

  // Записать отправку в корзину
  Future<void> recordTrashed({required int fileSize}) async {
    final currentTrashed = _box.get(_trashedKey, defaultValue: 0) as int;
    final currentFreed = _box.get(_freedBytesKey, defaultValue: 0) as int;
    await _box.put(_trashedKey, currentTrashed + 1);
    await _box.put(_freedBytesKey, currentFreed + fileSize);
    await recordViewed();
  }

  // Записать сохранение
  Future<void> recordKept() async {
    final current = _box.get(_keptKey, defaultValue: 0) as int;
    await _box.put(_keptKey, current + 1);
    await recordViewed();
  }

  // Записать пропуск
  Future<void> recordSkipped() async {
    final current = _box.get(_skippedKey, defaultValue: 0) as int;
    await _box.put(_skippedKey, current + 1);
  }

  Future<void> undoTrashed({required int fileSize}) async {
    final currentTrashed = _box.get(_trashedKey, defaultValue: 0) as int;
    final currentFreed = _box.get(_freedBytesKey, defaultValue: 0) as int;
    final currentViewed = _box.get(_viewedKey, defaultValue: 0) as int;
    await _box.put(_trashedKey, (currentTrashed - 1).clamp(0, 999999));
    await _box.put(_freedBytesKey, (currentFreed - fileSize).clamp(0, 999999999));
    await _box.put(_viewedKey, (currentViewed - 1).clamp(0, 999999));
  }

  Future<void> undoKept() async {
    final current = _box.get(_keptKey, defaultValue: 0) as int;
    final currentViewed = _box.get(_viewedKey, defaultValue: 0) as int;
    await _box.put(_keptKey, (current - 1).clamp(0, 999999));
    await _box.put(_viewedKey, (currentViewed - 1).clamp(0, 999999));
  }

  Future<void> undoSkipped() async {
    final current = _box.get(_skippedKey, defaultValue: 0) as int;
    await _box.put(_skippedKey, (current - 1).clamp(0, 999999));
  }

  // Сбросить статистику
  Future<void> reset() async {
    await _box.put(_viewedKey, 0);
    await _box.put(_trashedKey, 0);
    await _box.put(_keptKey, 0);
    await _box.put(_skippedKey, 0);
    await _box.put(_freedBytesKey, 0);
  }
}