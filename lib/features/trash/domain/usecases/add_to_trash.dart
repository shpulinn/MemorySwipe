import '../entities/trash_item_entity.dart';
import '../repositories/trash_repository.dart';

class AddToTrash {
  final TrashRepository _repository;

  AddToTrash(this._repository);

  Future<void> call(TrashItemEntity item) {
    return _repository.addToTrash(item);
  }
}