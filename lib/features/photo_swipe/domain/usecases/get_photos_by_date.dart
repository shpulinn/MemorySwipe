import '../entities/photo_entity.dart';
import '../repositories/photo_repository.dart';
import '../../../../core/constants/app_constants.dart';

class GetPhotosByDate {
  final PhotoRepository _repository;

  GetPhotosByDate(this._repository);

  Future<List<PhotoEntity>> call({
    required DateTime date,
    int page = 0,
  }) {
    return _repository.getPhotosByDate(
      date: date,
      page: page,
      pageSize: AppConstants.photoPageSize,
    );
  }
}