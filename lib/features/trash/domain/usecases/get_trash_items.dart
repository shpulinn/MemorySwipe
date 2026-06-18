import '../entities/trash_item_entity.dart';
import '../repositories/trash_repository.dart';

class GetTrashItems {
  final TrashRepository _repository;

  GetTrashItems(this._repository);

  Future<List<TrashItemEntity>> call() {
    return _repository.getTrashItems();
  }
}