class PhotoEntity {
  final String id;
  final String path;
  final DateTime createdAt;
  final int width;
  final int height;
  final int fileSize;

  const PhotoEntity({
    required this.id,
    required this.path,
    required this.createdAt,
    required this.width,
    required this.height,
    required this.fileSize,
  });
}