import '../repositories/trash_repository.dart';

class RestoreFromTrash {
  final TrashRepository _repository;

  RestoreFromTrash(this._repository);

  Future<void> call(String photoId) {
    return _repository.restoreFromTrash(photoId);
  }
}