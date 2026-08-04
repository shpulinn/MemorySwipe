import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memory_swipe/features/photo_swipe/data/repositories/photo_repository_impl.dart';
import '../../domain/repositories/photo_repository.dart';
import '../../domain/usecases/get_photos_for_today.dart';
import '../../domain/usecases/get_recent_photos.dart';
import '../../domain/usecases/get_screenshots.dart';
import '../../domain/usecases/get_photos_by_date.dart';
import '../../domain/usecases/request_permission.dart';
import '../../domain/usecases/mark_photo_as_viewed.dart';
import '../../domain/entities/photo_entity.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../widgets/swipe_indicator.dart';

// Репозиторий
final photoRepositoryProvider = Provider<PhotoRepository>((ref) {
  return PhotoRepositoryImpl();
});

// Use cases
final getPhotosForTodayProvider = Provider<GetPhotosForToday>((ref) {
  return GetPhotosForToday(ref.read(photoRepositoryProvider));
});

final getRecentPhotosProvider = Provider<GetRecentPhotos>((ref) {
  return GetRecentPhotos(ref.read(photoRepositoryProvider));
});

final getScreenshotsProvider = Provider<GetScreenshots>((ref) {
  return GetScreenshots(ref.read(photoRepositoryProvider));
});

final getPhotosByDateProvider = Provider<GetPhotosByDate>((ref) {
  return GetPhotosByDate(ref.read(photoRepositoryProvider));
});

final requestPermissionProvider = Provider<RequestPermission>((ref) {
  return RequestPermission(ref.read(photoRepositoryProvider));
});

final markPhotoAsViewedProvider = Provider<MarkPhotoAsViewed>((ref) {
  return MarkPhotoAsViewed(ref.read(photoRepositoryProvider));
});

// Режимы просмотра фото
enum PhotoMode { today, recent, screenshots, byDate }

// Состояние экрана свайпов
class PhotoSwipeState {
  final List<PhotoEntity> photos;
  final bool isLoading;
  final bool hasMore;
  final bool hasPermission;
  final String? error;
  final PhotoMode mode;
  final DateTime? selectedDate;
  final int currentPage;
  final List<LastAction> actionHistory;

  const PhotoSwipeState({
    this.photos = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.hasPermission = false,
    this.error,
    this.mode = PhotoMode.today,
    this.selectedDate,
    this.currentPage = 0,
    this.actionHistory = const [], 
  });

  PhotoSwipeState copyWith({
    List<PhotoEntity>? photos,
    bool? isLoading,
    bool? hasMore,
    bool? hasPermission,
    String? error,
    PhotoMode? mode,
    DateTime? selectedDate,
    int? currentPage,
    List<LastAction>? actionHistory,
  }) {
    return PhotoSwipeState(
      photos: photos ?? this.photos,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      hasPermission: hasPermission ?? this.hasPermission,
      error: error ?? this.error,
      mode: mode ?? this.mode,
      selectedDate: selectedDate ?? this.selectedDate,
      currentPage: currentPage ?? this.currentPage,
      actionHistory: actionHistory ?? this.actionHistory,
    );
  }

    // Удобный геттер — есть ли что отменять
  bool get canUndo => actionHistory.isNotEmpty;

  // Последнее действие
  LastAction? get lastAction =>
      actionHistory.isNotEmpty ? actionHistory.last : null;
}

// Последнее действие пользователя для отмены
class LastAction {
  final PhotoEntity photo;
  final SwipeDirection direction;

  const LastAction({
    required this.photo,
    required this.direction,
  });
}

// Notifier — управляет состоянием экрана свайпов
class PhotoSwipeNotifier extends StateNotifier<PhotoSwipeState> {
  final RequestPermission _requestPermission;
  final GetPhotosForToday _getPhotosForToday;
  final GetRecentPhotos _getRecentPhotos;
  final GetScreenshots _getScreenshots;
  final GetPhotosByDate _getPhotosByDate;
  final MarkPhotoAsViewed _markAsViewed;

  PhotoSwipeNotifier({
    required RequestPermission requestPermission,
    required GetPhotosForToday getPhotosForToday,
    required GetRecentPhotos getRecentPhotos,
    required GetScreenshots getScreenshots,
    required GetPhotosByDate getPhotosByDate,
    required MarkPhotoAsViewed markAsViewed,
  })  : _requestPermission = requestPermission,
        _getPhotosForToday = getPhotosForToday,
        _getRecentPhotos = getRecentPhotos,
        _getScreenshots = getScreenshots,
        _getPhotosByDate = getPhotosByDate,
        _markAsViewed = markAsViewed,
        super(const PhotoSwipeState());

  // Инициализация — запрашиваем разрешение и загружаем фото
  Future<void> initialize() async {
    state = state.copyWith(isLoading: true, error: null);

    bool hasPermission = false;

    try {
      hasPermission = await _requestPermission();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasPermission: false,
        error: 'Доступ к фото недоступен в этом режиме',
      );
      return;
    }

    if (!hasPermission) {
      state = state.copyWith(
        isLoading: false,
        hasPermission: false,
        error: 'Нет доступа к фотографиям',
      );
      return;
    }

    state = state.copyWith(hasPermission: true);
    await loadPhotos();
  }

  // Загрузить фото согласно текущему режиму
  Future<void> loadPhotos({bool reset = true}) async {
    if (state.isLoading && !reset) return;

    final page = reset ? 0 : state.currentPage;

    state = state.copyWith(
      isLoading: true,
      error: null,
      photos: reset ? [] : state.photos,
      currentPage: page,
    );

    try {
      final newPhotos = await _fetchByMode(page);

      state = state.copyWith(
        photos: reset ? newPhotos : [...state.photos, ...newPhotos],
        isLoading: false,
        hasMore: newPhotos.isNotEmpty,
        currentPage: page + 1,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Ошибка загрузки фотографий',
      );
    }
  }

  // Загрузить следующую страницу
  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoading) return;
    await loadPhotos(reset: false);
  }

  // Сменить режим
  Future<void> changeMode(PhotoMode mode, {DateTime? date}) async {
    state = state.copyWith(
      mode: mode,
      selectedDate: date,
      currentPage: 0,
      actionHistory: [], // сбрасываем историю при смене режима
    );
    await loadPhotos();
  }

  // Убрать фото из списка (после свайпа)
  Future<void> removePhoto(String photoId, {SwipeDirection? direction}) async {
    final photo = state.photos.firstWhere((p) => p.id == photoId);
    await _markAsViewed(photoId);

    final newHistory = direction != null
        ? [
            ...state.actionHistory,
            LastAction(photo: photo, direction: direction),
          ].reversed.take(5).toList().reversed.toList()
        : state.actionHistory;

    state = state.copyWith(
      photos: state.photos.where((p) => p.id != photoId).toList(),
      actionHistory: newHistory,
    );
  }

  // Пропустить фото — убираем из текущей сессии но не помечаем просмотренным
  Future<void> skipPhoto(String photoId) async {
    final photo = state.photos.firstWhere((p) => p.id == photoId);

    final newHistory = [
      ...state.actionHistory,
      LastAction(photo: photo, direction: SwipeDirection.up),
    ].reversed.take(5).toList().reversed.toList();

    state = state.copyWith(
      photos: state.photos.where((p) => p.id != photoId).toList(),
      actionHistory: newHistory,
    );
  }

  Future<void> undoLastAction() async {
    if (state.actionHistory.isEmpty) return;

    final newHistory = List<LastAction>.from(state.actionHistory);
    final last = newHistory.removeLast();

    // Возвращаем фото в начало стека
    final updatedPhotos = [last.photo, ...state.photos];

    // Убираем из просмотренных если было влево или вправо
    if (last.direction != SwipeDirection.up) {
      await Hive.box<bool>(AppConstants.viewedPhotosBoxName)
          .delete(last.photo.id);
    }

    state = state.copyWith(
      photos: updatedPhotos,
      actionHistory: newHistory,
    );
  }

  Future<void> undoAll() async {
    final history = List<LastAction>.from(state.actionHistory);

    var updatedPhotos = List<PhotoEntity>.from(state.photos);

    for (final action in history.reversed) {
      updatedPhotos = [action.photo, ...updatedPhotos];
      if (action.direction != SwipeDirection.up) {
        await Hive.box<bool>(AppConstants.viewedPhotosBoxName)
            .delete(action.photo.id);
      }
    }

    state = state.copyWith(
      photos: updatedPhotos,
      actionHistory: [],
    );
  }

  // Сбросить все просмотренные фото
  Future<void> resetViewed() async {
    await Hive.box<bool>(AppConstants.viewedPhotosBoxName).clear();
    await loadPhotos();
  }

  void clearPhotos() {
    // Просто показываем EmptyState — не сбрасываем просмотренные
    state = state.copyWith(
      photos: [],
      hasMore: true, // сохраняем возможность загрузить снова
      actionHistory: [],
    );
  }

  // Убрать конкретное фото из истории действий (при восстановлении из корзины)
  void removeFromHistory(String photoId) {
    state = state.copyWith(
      actionHistory: state.actionHistory
          .where((a) => a.photo.id != photoId)
          .toList(),
    );
  }

  Future<List<PhotoEntity>> _fetchByMode(int page) async {
    switch (state.mode) {
      case PhotoMode.today:
        return _getPhotosForToday(page: page);
      case PhotoMode.recent:
        return _getRecentPhotos(page: page);
      case PhotoMode.screenshots:
        return _getScreenshots(page: page);
      case PhotoMode.byDate:
        if (state.selectedDate == null) return [];
        return _getPhotosByDate(date: state.selectedDate!, page: page);
    }
  }
}

// Provider для PhotoSwipeNotifier
final photoSwipeProvider =
    StateNotifierProvider<PhotoSwipeNotifier, PhotoSwipeState>((ref) {
  return PhotoSwipeNotifier(
    requestPermission: ref.read(requestPermissionProvider),
    getPhotosForToday: ref.read(getPhotosForTodayProvider),
    getRecentPhotos: ref.read(getRecentPhotosProvider),
    getScreenshots: ref.read(getScreenshotsProvider),
    getPhotosByDate: ref.read(getPhotosByDateProvider),
    markAsViewed: ref.read(markPhotoAsViewedProvider),
  );
});