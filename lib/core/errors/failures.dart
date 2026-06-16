abstract class Failure {
  final String message;
  const Failure(this.message);
}

class PermissionFailure extends Failure {
  const PermissionFailure() : super('Нет доступа к фотографиям');
}

class StorageFailure extends Failure {
  const StorageFailure(super.message);
}

class PhotoLoadFailure extends Failure {
  const PhotoLoadFailure() : super('Не удалось загрузить фотографии');
}