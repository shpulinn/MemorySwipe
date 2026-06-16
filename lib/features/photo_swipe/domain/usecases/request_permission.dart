import '../repositories/photo_repository.dart';

class RequestPermission {
  final PhotoRepository _repository;

  RequestPermission(this._repository);

  Future<bool> call() {
    return _repository.requestPermission();
  }
}