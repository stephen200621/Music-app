import 'song.dart';

class RecommendationItem {
  final Song song;
  final double score; // 0.0 to 100.0 normalized
  final String reason;
  final String category;

  const RecommendationItem({
    required this.song,
    required this.score,
    required this.reason,
    required this.category,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecommendationItem &&
          runtimeType == other.runtimeType &&
          song.id == other.song.id;

  @override
  int get hashCode => song.id.hashCode;
}
