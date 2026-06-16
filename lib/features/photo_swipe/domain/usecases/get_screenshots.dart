import '../entities/photo_entity.dart';
import '../repositories/photo_repository.dart';
import '../../../../core/constants/app_constants.dart';

class GetScreenshots {
  final PhotoRepository _repository;

  GetScreenshots(this._repository);

  Future<List<PhotoEntity>> call({int page = 0}) {
    return _repository.getScreenshots(
      page: page,
      pageSize: AppConstants.photoPageSize,
    );
  }
}