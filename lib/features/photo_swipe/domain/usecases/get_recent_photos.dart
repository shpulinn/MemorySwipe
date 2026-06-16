import '../entities/photo_entity.dart';
import '../repositories/photo_repository.dart';
import '../../../../core/constants/app_constants.dart';

class GetRecentPhotos {
  final PhotoRepository _repository;

  GetRecentPhotos(this._repository);

  Future<List<PhotoEntity>> call({int page = 0}) {
    return _repository.getRecentPhotos(
      page: page,
      pageSize: AppConstants.photoPageSize,
    );
  }
}