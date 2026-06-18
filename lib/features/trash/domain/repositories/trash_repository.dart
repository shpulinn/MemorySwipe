import '../entities/trash_item_entity.dart';

abstract class TrashRepository {
  // Получить все элементы корзины
  Future<List<TrashItemEntity>> getTrashItems();

  // Добавить фото в корзину
  Future<void> addToTrash(TrashItemEntity item);

  // Восстановить фото из корзины
  Future<void> restoreFromTrash(String photoId);

  // Удалить фото навсегда
  Future<bool> deletePermanently(String photoId);

  // Очистить всю корзину
  Future<bool> clearTrash();

  // Количество элементов в корзине
  Future<int> getTrashCount();

  // Удалить несколько фото сразу
  Future<bool> deleteBatch(List<String> photoIds);
}