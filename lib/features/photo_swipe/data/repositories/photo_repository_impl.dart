import 'package:photo_manager/photo_manager.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../domain/entities/photo_entity.dart';
import '../../domain/repositories/photo_repository.dart';
import '../../../../core/constants/app_constants.dart';

class PhotoRepositoryImpl implements PhotoRepository {
  // Hive box для хранения просмотренных фото
  Box<bool> get _viewedBox => Hive.box<bool>(AppConstants.viewedPhotosBoxName);

  @override
  Future<bool> requestPermission() async {
    final result = await PhotoManager.requestPermissionExtend(
      requestOption: const PermissionRequestOption(
        androidPermission: AndroidPermission(
          type: RequestType.image,
          mediaLocation: true,
        ),
      ),
    );
    return result.isAuth;
  }

  @override
  Future<List<PhotoEntity>> getPhotosForToday({
    required int page,
    required int pageSize,
  }) async {
    final now = DateTime.now();
    final allPhotos = <PhotoEntity>[];

    // Ищем фото за этот день в каждом из прошлых лет
    for (int year = now.year - 1;
        year >= now.year - AppConstants.yearsToLookBack;
        year--) {
      // Начало дня
      final dayStart = DateTime(year, now.month, now.day, 0, 0, 0);
      // Конец дня
      final dayEnd = DateTime(year, now.month, now.day, 23, 59, 59);

      final photos = await _fetchPhotosInRange(
        from: dayStart,
        to: dayEnd,
        page: 0,
        pageSize: pageSize,
      );

      allPhotos.addAll(photos);
    }

    // Фильтруем просмотренные
    final filtered = allPhotos
        .where((p) => !(_viewedBox.get(p.id) ?? false))
        .toList();

    // Применяем пагинацию вручную
    final start = page * pageSize;
    if (start >= filtered.length) return [];
    final end = (start + pageSize).clamp(0, filtered.length);
    return filtered.sublist(start, end);
  }

  @override
  Future<List<PhotoEntity>> getRecentPhotos({
    required int page,
    required int pageSize,
  }) async {
    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      filterOption: FilterOptionGroup(
        orders: [
          const OrderOption(type: OrderOptionType.createDate, asc: false),
        ],
      ),
    );

    if (albums.isEmpty) return [];

    // Загружаем с запасом чтобы после фильтрации осталось достаточно
    final assets = await albums.first.getAssetListPaged(
      page: page,
      size: pageSize * 3,
    );

    final all = await _convertAssets(assets);
    final filtered = all.where((p) => !(_viewedBox.get(p.id) ?? false)).toList();
    
    if (filtered.isEmpty) return [];
    final end = pageSize.clamp(0, filtered.length);
    return filtered.sublist(0, end);
  }

  @override
  Future<List<PhotoEntity>> getScreenshots({
    required int page,
    required int pageSize,
  }) async {
    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
    );

    final screenshotAlbum = albums.where((a) {
      final name = a.name.toLowerCase();
      return name.contains('screenshot') || name.contains('скриншот');
    }).firstOrNull;

    if (screenshotAlbum == null) return [];

    final assets = await screenshotAlbum.getAssetListPaged(
      page: page,
      size: pageSize * 3,
    );

    final all = await _convertAssets(assets);
    final filtered = all.where((p) => !(_viewedBox.get(p.id) ?? false)).toList();
    
    if (filtered.isEmpty) return [];
    final end = pageSize.clamp(0, filtered.length);
    return filtered.sublist(0, end);
  }

  @override
  Future<List<PhotoEntity>> getPhotosByDate({
    required DateTime date,
    required int page,
    required int pageSize,
  }) async {
    final dayStart = DateTime(date.year, date.month, date.day, 0, 0, 0);
    final dayEnd = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final all = await _fetchPhotosInRange(
      from: dayStart,
      to: dayEnd,
      page: page,
      pageSize: pageSize * 3,
    );

    final filtered = all.where((p) => !(_viewedBox.get(p.id) ?? false)).toList();
    if (filtered.isEmpty) return [];
    final end = pageSize.clamp(0, filtered.length);
    return filtered.sublist(0, end);
  }

  @override
  Future<void> markAsViewed(String photoId) async {
    await _viewedBox.put(photoId, true);
  }

  @override
  Future<bool> isViewed(String photoId) async {
    return _viewedBox.get(photoId) ?? false;
  }

  // Вспомогательный метод — получить фото за период
  Future<List<PhotoEntity>> _fetchPhotosInRange({
    required DateTime from,
    required DateTime to,
    required int page,
    required int pageSize,
  }) async {
    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      filterOption: FilterOptionGroup(
        createTimeCond: DateTimeCond(min: from, max: to),
        orders: [
          const OrderOption(type: OrderOptionType.createDate, asc: false),
        ],
      ),
    );

    if (albums.isEmpty) return [];

    final assets = await albums.first.getAssetListPaged(
      page: page,
      size: pageSize,
    );

    return _convertAssets(assets);
  }

  // Конвертируем формат photo_manager в наш формат
  Future<List<PhotoEntity>> _convertAssets(List<AssetEntity> assets) async {
    final result = <PhotoEntity>[];

    for (final asset in assets) {
      final file = await asset.file;
      if (file == null) continue;

      result.add(PhotoEntity(
        id: asset.id,
        path: file.path,
        createdAt: asset.createDateTime,
        width: asset.width,
        height: asset.height,
        fileSize: await file.length(),
      ));
    }

    return result;
  }
}