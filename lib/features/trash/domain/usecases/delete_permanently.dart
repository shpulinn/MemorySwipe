import '../repositories/trash_repository.dart';

class DeletePermanently {
  final TrashRepository _repository;

  DeletePermanently(this._repository);

  Future<bool> call(String photoId) {
    return _repository.deletePermanently(photoId);
  }
}