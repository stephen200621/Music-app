import 'dart:math';
import '../../core/constants/app_constants.dart';
import '../../data/models/music_mode.dart';
import '../../data/models/play_history_item.dart';
import '../../data/models/recommendation_item.dart';
import '../../data/models/song.dart';
import '../../data/repositories/history_repository.dart';
import '../../data/repositories/music_repository.dart';

class AiRecommendationEngine {
  final MusicRepository _musicRepo;
  final HistoryRepository _historyRepo;

  AiRecommendationEngine({
    MusicRepository? musicRepo,
    HistoryRepository? historyRepo,
  })  : _musicRepo = musicRepo ?? MusicRepository(),
        _historyRepo = historyRepo ?? HistoryRepository();

  /// Calculate personalized recommendations for all songs given current mode and listening history
  Future<List<RecommendationItem>> generateRecommendations({
    required MusicMode currentMode,
    String? currentPlayingSongId,
    int limit = 20,
  }) async {
    final allSongs = await _musicRepo.getAllSongs();
    if (allSongs.isEmpty) return [];

    final history = await _historyRepo.getHistory(limit: 200);

    // Compute user preference profile
    final Map<String, int> artistPlayCounts = {};
    final Map<String, int> genrePlayCounts = {};
    final Map<String, int> songSkipCounts = {};
    final Map<String, int> songCompletedCounts = {};
    final Set<String> recentlyPlayedIds = {};

    final now = DateTime.now().millisecondsSinceEpoch;
    final threeHoursAgo = now - AppConstants.recencyPenaltyWindow.inMilliseconds;

    for (final item in history) {
      if (item.startedAt >= threeHoursAgo) {
        recentlyPlayedIds.add(item.songId);
      }
      if (item.eventType == HistoryEventType.skipped) {
        songSkipCounts[item.songId] = (songSkipCounts[item.songId] ?? 0) + 1;
      } else if (item.eventType == HistoryEventType.completed || item.completionPercentage >= 80) {
        songCompletedCounts[item.songId] = (songCompletedCounts[item.songId] ?? 0) + 1;
      }
    }

    for (final song in allSongs) {
      if (song.playCount > 0) {
        artistPlayCounts[song.artist] = (artistPlayCounts[song.artist] ?? 0) + song.playCount;
        genrePlayCounts[song.genre] = (genrePlayCounts[song.genre] ?? 0) + song.playCount;
      }
    }

    final List<RecommendationItem> scoredItems = [];

    for (final song in allSongs) {
      // Avoid recommending current track
      if (song.id == currentPlayingSongId) continue;

      final double score = _calculateScore(
        song: song,
        mode: currentMode,
        artistPlays: artistPlayCounts[song.artist] ?? 0,
        genrePlays: genrePlayCounts[song.genre] ?? 0,
        skips: songSkipCounts[song.id] ?? 0,
        completions: songCompletedCounts[song.id] ?? 0,
        isRecentlyPlayed: recentlyPlayedIds.contains(song.id),
      );

      final String reason = _generateRationale(
        song: song,
        mode: currentMode,
        isFavorite: song.isFavorite,
        artistPlays: artistPlayCounts[song.artist] ?? 0,
        completions: songCompletedCounts[song.id] ?? 0,
        skips: songSkipCounts[song.id] ?? 0,
      );

      final String category = _assignCategory(
        song: song,
        mode: currentMode,
        isFavorite: song.isFavorite,
        playCount: song.playCount,
      );

      scoredItems.add(RecommendationItem(
        song: song,
        score: score.clamp(0.0, 100.0),
        reason: reason,
        category: category,
      ));
    }

    // Sort by descending score
    scoredItems.sort((a, b) => b.score.compareTo(a.score));

    return scoredItems.take(limit).toList();
  }

  /// Multi-signal scoring formula
  double _calculateScore({
    required Song song,
    required MusicMode mode,
    required int artistPlays,
    required int genrePlays,
    required int skips,
    required int completions,
    required bool isRecentlyPlayed,
  }) {
    double score = 50.0; // Base score

    // 1. Music Mode Alignment (Weight: 35%)
    // Energy difference delta: 0 (perfect match) to 1.0 (opposite)
    final double energyDiff = (song.energy - mode.targetEnergy).abs();
    final double modeAlignmentScore = (1.0 - energyDiff) * 35.0;
    score += modeAlignmentScore;

    // 2. Play Count & Completion Affinity (Weight: 25%)
    final double playBonus = min(song.playCount * 2.0, 15.0);
    final double completionBonus = min(completions * 3.0, 10.0);
    score += (playBonus + completionBonus);

    // 3. Artist & Genre Affinity (Weight: 15%)
    final double artistBonus = min(artistPlays * 1.5, 8.0);
    final double genreBonus = min(genrePlays * 1.0, 7.0);
    score += (artistBonus + genreBonus);

    // 4. Favorite Bonus (Weight: +15)
    if (song.isFavorite) {
      score += 15.0;
    }

    // 5. Penalties
    // Skip penalty (-5 per skip)
    score -= (skips * 5.0);

    // Recency penalty (avoids repeating songs played in last 3 hours)
    if (isRecentlyPlayed) {
      score -= 30.0;
    }

    return score;
  }

  String _generateRationale({
    required Song song,
    required MusicMode mode,
    required bool isFavorite,
    required int artistPlays,
    required int completions,
    required int skips,
  }) {
    final double energyDiff = (song.energy - mode.targetEnergy).abs();

    if (energyDiff < 0.15) {
      return 'Tailored for ${mode.title} vibe (${(song.energy * 100).toInt()}% energy match)';
    } else if (isFavorite) {
      return 'From your Loved tracks with high replay value';
    } else if (completions > 2) {
      return 'You consistently listen to this full track without skipping';
    } else if (artistPlays > 5) {
      return 'Because you frequently enjoy ${song.artist}';
    } else if (song.playCount == 0) {
      return 'Fresh discovery matching your library genre';
    } else {
      return 'Algorithmic alignment with your daily listening habits';
    }
  }

  String _assignCategory({
    required Song song,
    required MusicMode mode,
    required bool isFavorite,
    required int playCount,
  }) {
    final double energyDiff = (song.energy - mode.targetEnergy).abs();
    if (energyDiff < 0.2) {
      return '${mode.title} Vibes';
    }
    if (playCount == 0) {
      return 'Discover Something New';
    }
    if (isFavorite || playCount > 10) {
      return 'Because You Love This';
    }
    return 'Recommended For You';
  }
}
