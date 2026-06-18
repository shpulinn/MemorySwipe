import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/trash_repository_impl.dart';
import '../../domain/entities/trash_item_entity.dart';
import '../../domain/repositories/trash_repository.dart';
import '../../domain/usecases/add_to_trash.dart';
import '../../domain/usecases/get_trash_items.dart';
import '../../domain/usecases/restore_from_trash.dart';
import '../../domain/usecases/delete_permanently.dart';
import '../../domain/usecases/clear_trash.dart';

// Репозиторий
final trashRepositoryProvider = Provider<TrashRepository>((ref) {
  return TrashRepositoryImpl();
});

// Use cases
final addToTrashProvider = Provider<AddToTrash>((ref) {
  return AddToTrash(ref.read(trashRepositoryProvider));
});

final getTrashItemsProvider = Provider<GetTrashItems>((ref) {
  return GetTrashItems(ref.read(trashRepositoryProvider));
});

final restoreFromTrashProvider = Provider<RestoreFromTrash>((ref) {
  return RestoreFromTrash(ref.read(trashRepositoryProvider));
});

final deletePermanentlyProvider = Provider<DeletePermanently>((ref) {
  return DeletePermanently(ref.read(trashRepositoryProvider));
});

final clearTrashProvider = Provider<ClearTrash>((ref) {
  return ClearTrash(ref.read(trashRepositoryProvider));
});

// Состояние экрана корзины
class TrashState {
  final List<TrashItemEntity> items;
  final bool isLoading;
  final String? error;
  final Set<String> selectedIds;

  const TrashState({
    this.items = const [],
    this.isLoading = false,
    this.error,
    this.selectedIds = const {},
  });

  TrashState copyWith({
    List<TrashItemEntity>? items,
    bool? isLoading,
    String? error,
    Set<String>? selectedIds,
  }) {
    return TrashState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      selectedIds: selectedIds ?? this.selectedIds,
    );
  }

  // Общий размер файлов в корзине
  int get totalSize => items.fold(0, (sum, item) => sum + item.fileSize);

  // Есть ли выбранные элементы
  bool get hasSelection => selectedIds.isNotEmpty;
}

// Notifier
class TrashNotifier extends StateNotifier<TrashState> {
  final GetTrashItems _getTrashItems;
  final RestoreFromTrash _restoreFromTrash;
  final DeletePermanently _deletePermanently;
  final ClearTrash _clearTrash;
  final TrashRepository _repository;

  TrashNotifier({
    required GetTrashItems getTrashItems,
    required RestoreFromTrash restoreFromTrash,
    required DeletePermanently deletePermanently,
    required ClearTrash clearTrash,
    required TrashRepository repository,
  })  : _getTrashItems = getTrashItems,
        _restoreFromTrash = restoreFromTrash,
        _deletePermanently = deletePermanently,
        _clearTrash = clearTrash,
        _repository = repository,
        super(const TrashState());

  // Загрузить содержимое корзины
  Future<void> loadItems() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final items = await _getTrashItems();
      state = state.copyWith(items: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Не удалось загрузить корзину',
      );
    }
  }

  // Восстановить фото
  Future<void> restore(String photoId) async {
    try {
      await _restoreFromTrash(photoId);
      state = state.copyWith(
        items: state.items.where((i) => i.photoId != photoId).toList(),
        selectedIds: state.selectedIds..remove(photoId),
      );
    } catch (e) {
      state = state.copyWith(error: 'Не удалось восстановить фото');
    }
  }

  // Удалить одно фото навсегда
  Future<bool> deletePermanently(String photoId) async {
    final success = await _deletePermanently(photoId);
    if (success) {
      state = state.copyWith(
        items: state.items.where((i) => i.photoId != photoId).toList(),
        selectedIds: state.selectedIds..remove(photoId),
      );
    } else {
      state = state.copyWith(error: 'Не удалось удалить фото');
    }
    return success;
  }

  // Удалить выбранные фото
  Future<void> deleteSelected() async {
    final ids = state.selectedIds.toList();
    // Удаляем все сразу одним вызовом
    final success = await _repository.deleteBatch(ids);
    if (success) {
      final remaining = state.items
          .where((i) => !state.selectedIds.contains(i.photoId))
          .toList();
      state = state.copyWith(items: remaining, selectedIds: {});
    }
  }

  // Очистить всю корзину
  Future<void> clearAll() async {
    state = state.copyWith(isLoading: true);
    await _clearTrash();
    state = state.copyWith(items: [], isLoading: false, selectedIds: {});
  }

  // Выбрать/снять выбор элемента
  void toggleSelection(String photoId) {
    final newSelected = Set<String>.from(state.selectedIds);
    if (newSelected.contains(photoId)) {
      newSelected.remove(photoId);
    } else {
      newSelected.add(photoId);
    }
    state = state.copyWith(selectedIds: newSelected);
  }

  // Снять все выборы
  void clearSelection() {
    state = state.copyWith(selectedIds: {});
  }
}

// Provider
final trashNotifierProvider =
    StateNotifierProvider<TrashNotifier, TrashState>((ref) {
  return TrashNotifier(
    getTrashItems: ref.read(getTrashItemsProvider),
    restoreFromTrash: ref.read(restoreFromTrashProvider),
    deletePermanently: ref.read(deletePermanentlyProvider),
    clearTrash: ref.read(clearTrashProvider),
    repository: ref.read(trashRepositoryProvider),
  );
});