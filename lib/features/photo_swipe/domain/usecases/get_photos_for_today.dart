import '../entities/photo_entity.dart';
import '../repositories/photo_repository.dart';
import '../../../../core/constants/app_constants.dart';

class GetPhotosForToday {
  final PhotoRepository _repository;

  GetPhotosForToday(this._repository);

  Future<List<PhotoEntity>> call({int page = 0}) {
    return _repository.getPhotosForToday(
      page: page,
      pageSize: AppConstants.photoPageSize,
    );
  }
}