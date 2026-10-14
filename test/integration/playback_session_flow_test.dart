import 'package:flutter_test/flutter_test.dart';
import '../../lib/data/database/tables.dart';
import '../../lib/data/models/playback_session_state.dart';
import '../../lib/data/models/song.dart';

void main() {
  group('Playback Session Integration & Schema Flow Tests', () {
    test('PlaybackSessionState serialization and deserialization retains exact values', () {
      final now = DateTime.now().millisecondsSinceEpoch;
      final original = PlaybackSessionState(
        currentSongId: 'vybe_track_01',
        positionMs: 64200,
        currentQueueIndex: 2,
        selectedMode: 'workout',
        shuffleEnabled: true,
        repeatMode: 'one',
        updatedAt: now,
      );

      final map = original.toMap();
      final restored = PlaybackSessionState.fromMap(map);

      expect(restored.currentSongId, 'vybe_track_01');
      expect(restored.positionMs, 64200);
      expect(restored.currentQueueIndex, 2);
      expect(restored.selectedMode, 'workout');
      expect(restored.shuffleEnabled, isTrue);
      expect(restored.repeatMode, 'one');
      expect(restored.updatedAt, now);
    });

    test('SQLite schema includes all 9 required tables and indexes', () {
      expect(DbTables.createSongsTable.contains(DbTables.songs), isTrue);
      expect(DbTables.createPlaylistsTable.contains(DbTables.playlists), isTrue);
      expect(DbTables.createPlaylistSongsTable.contains(DbTables.playlistSongs), isTrue);
      expect(DbTables.createLikedSongsTable.contains(DbTables.likedSongs), isTrue);
      expect(DbTables.createPlayHistoryTable.contains(DbTables.playHistory), isTrue);
      expect(DbTables.createListeningPreferencesTable.contains(DbTables.listeningPreferences), isTrue);
      expect(DbTables.createAppSettingsTable.contains(DbTables.appSettings), isTrue);
      expect(DbTables.createPlaybackSessionTable.contains(DbTables.playbackSession), isTrue);
      expect(DbTables.createPlaybackQueueTable.contains(DbTables.playbackQueue), isTrue);
      expect(DbTables.createIndexes.length >= 6, isTrue);
    });

    test('Song model copyWith properly preserves favorites and energy level', () {
      final song = const Song(
        id: 'test_1',
        title: 'Cyber Drift',
        fileUri: '/media/song.mp3',
        dateAdded: 100,
        lastScannedAt: 100,
        isFavorite: false,
        energy: 0.85,
      );

      final updated = song.copyWith(isFavorite: true);
      expect(updated.isFavorite, isTrue);
      expect(updated.energy, 0.85);
      expect(updated.title, 'Cyber Drift');
    });
  });
}
