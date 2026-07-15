import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/statistics_service.dart';
import '../../domain/entities/statistics_entity.dart';

final statisticsServiceProvider = Provider<StatisticsService>((ref) {
  return StatisticsService();
});

final statisticsProvider = Provider<StatisticsEntity>((ref) {
  return ref.read(statisticsServiceProvider).getStatistics();
});

class StatisticsNotifier extends StateNotifier<StatisticsEntity> {
  final StatisticsService _service;

  StatisticsNotifier(this._service) : super(const StatisticsEntity()) {
    _load();
  }

  void _load() {
    state = _service.getStatistics();
  }

  Future<void> recordTrashed({required int fileSize}) async {
    await _service.recordTrashed(fileSize: fileSize);
    _load();
  }

  Future<void> recordKept() async {
    await _service.recordKept();
    _load();
  }

  Future<void> recordSkipped() async {
    await _service.recordSkipped();
    _load();
  }

  Future<void> undoTrashed({required int fileSize}) async {
    await _service.undoTrashed(fileSize: fileSize);
    // Небольшая задержка чтобы Hive успел записать
    await Future.delayed(const Duration(milliseconds: 50));
    _load();
  }

  Future<void> undoKept() async {
    await _service.undoKept();
    await Future.delayed(const Duration(milliseconds: 50));
    _load();
  }

  Future<void> undoSkipped() async {
    await _service.undoSkipped();
    await Future.delayed(const Duration(milliseconds: 50));
    _load();
  }

  Future<void> reset() async {
    await _service.reset();
    _load();
  }
}

final statisticsNotifierProvider =
    StateNotifierProvider<StatisticsNotifier, StatisticsEntity>((ref) {
  return StatisticsNotifier(ref.read(statisticsServiceProvider));
});