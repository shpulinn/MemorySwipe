import '../entities/photo_entity.dart';
import '../../../../core/errors/failures.dart';

// Either — это тип который означает "либо ошибка, либо результат"
// Мы его опишем чуть позже, пока используем простой Future
abstract class PhotoRepository {
  // Получить фото "в этот день" прошлых лет
  Future<List<PhotoEntity>> getPhotosForToday({
    required int page,
    required int pageSize,
  });

  // Получить последние фото
  Future<List<PhotoEntity>> getRecentPhotos({
    required int page,
    required int pageSize,
  });

  // Получить скриншоты
  Future<List<PhotoEntity>> getScreenshots({
    required int page,
    required int pageSize,
  });

  // Получить фото за конкретную дату
  Future<List<PhotoEntity>> getPhotosByDate({
    required DateTime date,
    required int page,
    required int pageSize,
  });

  // Проверить есть ли разрешение на доступ к галерее
  Future<bool> requestPermission();

  // Пометить фото как просмотренное (чтобы не показывать снова)
  Future<void> markAsViewed(String photoId);

  // Проверить просмотрено ли фото
  Future<bool> isViewed(String photoId);
}