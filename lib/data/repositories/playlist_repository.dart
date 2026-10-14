import 'package:sqflite/sqflite.dart';
import '../database/app_database.dart';
import '../database/tables.dart';
import '../models/playlist.dart';
import '../models/song.dart';

class PlaylistRepository {
  final AppDatabase _dbProvider;

  PlaylistRepository({AppDatabase? dbProvider})
      : _dbProvider = dbProvider ?? AppDatabase.instance;

  Future<Database> get _db => _dbProvider.database;

  /// Fetch all playlists with song counts
  Future<List<Playlist>> getAllPlaylists() async {
    final db = await _db;
    final results = await db.rawQuery('''
      SELECT p.*, COUNT(ps.id) AS song_count
      FROM ${DbTables.playlists} p
      LEFT JOIN ${DbTables.playlistSongs} ps ON p.id = ps.playlist_id
      GROUP BY p.id
      ORDER BY p.sort_order ASC, p.created_at DESC
    ''');

    return results
        .map((row) => Playlist.fromMap(
              row,
              songCount: (row['song_count'] as num?)?.toInt() ?? 0,
            ))
        .toList();
  }

  /// Create a new playlist
  Future<Playlist> createPlaylist(String name) async {
    final db = await _db;
    final now = DateTime.now().millisecondsSinceEpoch;
    final id = 'pl_${now}_${DateTime.now().microsecond}';

    final playlist = Playlist(
      id: id,
      name: name.trim(),
      createdAt: now,
      updatedAt: now,
      sortOrder: 0,
      songCount: 0,
    );

    await db.insert(DbTables.playlists, playlist.toMap());
    return playlist;
  }

  /// Delete a playlist
  Future<void> deletePlaylist(String playlistId) async {
    final db = await _db;
    await db.delete(
      DbTables.playlists,
      where: 'id = ?',
      whereArgs: [playlistId],
    );
  }

  /// Add a song to a playlist
  Future<void> addSongToPlaylist(String playlistId, String songId) async {
    final db = await _db;
    final countResult = await db.rawQuery(
      'SELECT MAX(position) as max_pos FROM ${DbTables.playlistSongs} WHERE playlist_id = ?',
      [playlistId],
    );
    final maxPos = (countResult.first['max_pos'] as num?)?.toInt() ?? -1;

    await db.insert(
      DbTables.playlistSongs,
      {
        'playlist_id': playlistId,
        'song_id': songId,
        'position': maxPos + 1,
        'added_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get songs inside a playlist
  Future<List<Song>> getPlaylistSongs(String playlistId) async {
    final db = await _db;
    final results = await db.rawQuery('''
      SELECT s.*, 
             CASE WHEN l.song_id IS NOT NULL THEN 1 ELSE 0 END AS is_favorite
      FROM ${DbTables.playlistSongs} ps
      INNER JOIN ${DbTables.songs} s ON ps.song_id = s.id
      LEFT JOIN ${DbTables.likedSongs} l ON s.id = l.song_id
      WHERE ps.playlist_id = ?
      ORDER BY ps.position ASC
    ''', [playlistId]);

    return results.map((map) => Song.fromMap(map)).toList();
  }

  /// Remove song from playlist
  Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    final db = await _db;
    await db.delete(
      DbTables.playlistSongs,
      where: 'playlist_id = ? AND song_id = ?',
      whereArgs: [playlistId, songId],
    );
  }

  /// Save current playback queue as a new playlist
  Future<Playlist> saveQueueAsPlaylist(String playlistName, List<Song> queueSongs) async {
    final playlist = await createPlaylist(playlistName);
    for (final song in queueSongs) {
      await addSongToPlaylist(playlist.id, song.id);
    }
    return playlist.copyWith(songCount: queueSongs.length);
  }
}
