import '../repositories/photo_repository.dart';

class MarkPhotoAsViewed {
  final PhotoRepository _repository;

  MarkPhotoAsViewed(this._repository);

  Future<void> call(String photoId) {
    return _repository.markAsViewed(photoId);
  }
}