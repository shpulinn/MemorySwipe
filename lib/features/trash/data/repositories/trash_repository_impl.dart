import 'package:hive_flutter/hive_flutter.dart';
import 'package:photo_manager/photo_manager.dart';
import '../../domain/entities/trash_item_entity.dart';
import '../../domain/repositories/trash_repository.dart';
import '../../../../core/constants/app_constants.dart';

class TrashRepositoryImpl implements TrashRepository {
  // Храним корзину как Map: photoId -> JSON строка с данными
  Box<String> get _trashBox => Hive.box<String>(AppConstants.trashBoxName);

  @override
  Future<List<TrashItemEntity>> getTrashItems() async {
    final items = <TrashItemEntity>[];

    for (final key in _trashBox.keys) {
      final value = _trashBox.get(key.toString());
      if (value != null) {
        final item = _parseItem(value);
        if (item != null) items.add(item);
      }
    }

    // Сортируем по дате удаления — новые сверху
    items.sort((a, b) => b.deletedAt.compareTo(a.deletedAt));
    return items;
  }

  @override
  Future<void> addToTrash(TrashItemEntity item) async {
    await _trashBox.put(item.photoId, _serializeItem(item));
  }

  @override
  Future<void> restoreFromTrash(String photoId) async {
    await _trashBox.delete(photoId);
  }

  @override
  Future<bool> deletePermanently(String photoId) async {
    try {
      final result = await PhotoManager.editor.deleteWithIds([photoId]);
      if (result.contains(photoId)) {
        await _trashBox.delete(photoId);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> clearTrash() async {
    try {
      final ids = _trashBox.keys.map((k) => k.toString()).toList();
      if (ids.isEmpty) return true;

      final result = await PhotoManager.editor.deleteWithIds(ids);
      for (final id in result) {
        await _trashBox.delete(id);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> deleteBatch(List<String> photoIds) async {
    try {
      if (photoIds.isEmpty) return true;
      final result = await PhotoManager.editor.deleteWithIds(photoIds);
      for (final id in result) {
        await _trashBox.delete(id);
      }
      return result.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<int> getTrashCount() async {
    return _trashBox.length;
  }

  // Сериализация: превращаем объект в строку для хранения в Hive
  String _serializeItem(TrashItemEntity item) {
    return '${item.photoId}|${item.photoPath}|${item.originalDate.millisecondsSinceEpoch}|${item.deletedAt.millisecondsSinceEpoch}|${item.fileSize}';
  }

  // Десериализация: превращаем строку обратно в объект
  TrashItemEntity? _parseItem(String value) {
    try {
      final parts = value.split('|');
      if (parts.length != 5) return null;
      return TrashItemEntity(
        photoId: parts[0],
        photoPath: parts[1],
        originalDate: DateTime.fromMillisecondsSinceEpoch(int.parse(parts[2])),
        deletedAt: DateTime.fromMillisecondsSinceEpoch(int.parse(parts[3])),
        fileSize: int.parse(parts[4]),
      );
    } catch (e) {
      return null;
    }
  }
}