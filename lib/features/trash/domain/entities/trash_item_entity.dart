class TrashItemEntity {
  final String photoId;
  final String photoPath;
  final DateTime originalDate;
  final DateTime deletedAt;
  final int fileSize;

  const TrashItemEntity({
    required this.photoId,
    required this.photoPath,
    required this.originalDate,
    required this.deletedAt,
    required this.fileSize,
  });
}