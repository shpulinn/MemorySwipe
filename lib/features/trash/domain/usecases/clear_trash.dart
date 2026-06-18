import '../repositories/trash_repository.dart';

class ClearTrash {
  final TrashRepository _repository;

  ClearTrash(this._repository);

  Future<bool> call() {
    return _repository.clearTrash();
  }
}