class StatisticsEntity {
  final int totalViewed;
  final int totalTrashed;
  final int totalKept;
  final int totalSkipped;
  final int freedBytes;

  const StatisticsEntity({
    this.totalViewed = 0,
    this.totalTrashed = 0,
    this.totalKept = 0,
    this.totalSkipped = 0,
    this.freedBytes = 0,
  });

  // Удобный геттер — размер в МБ
  double get freedMb => freedBytes / 1024 / 1024;

  StatisticsEntity copyWith({
    int? totalViewed,
    int? totalTrashed,
    int? totalKept,
    int? totalSkipped,
    int? freedBytes,
  }) {
    return StatisticsEntity(
      totalViewed: totalViewed ?? this.totalViewed,
      totalTrashed: totalTrashed ?? this.totalTrashed,
      totalKept: totalKept ?? this.totalKept,
      totalSkipped: totalSkipped ?? this.totalSkipped,
      freedBytes: freedBytes ?? this.freedBytes,
    );
  }
}