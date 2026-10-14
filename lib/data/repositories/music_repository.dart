import 'package:sqflite/sqflite.dart';
import '../database/app_database.dart';
import '../database/tables.dart';
import '../models/song.dart';

class MusicRepository {
  final AppDatabase _dbProvider;

  MusicRepository({AppDatabase? dbProvider})
      : _dbProvider = dbProvider ?? AppDatabase.instance;

  Future<Database> get _db => _dbProvider.database;

  /// Fetch all songs with joined favorite status
  Future<List<Song>> getAllSongs({String? query, String? sortBy}) async {
    final db = await _db;
    String sql = '''
      SELECT s.*, 
             CASE WHEN l.song_id IS NOT NULL THEN 1 ELSE 0 END AS is_favorite
      FROM ${DbTables.songs} s
      LEFT JOIN ${DbTables.likedSongs} l ON s.id = l.song_id
    ''';

    List<dynamic> args = [];
    if (query != null && query.trim().isNotEmpty) {
      sql += ' WHERE s.title LIKE ? OR s.artist LIKE ? OR s.album LIKE ?';
      final match = '%${query.trim()}%';
      args.addAll([match, match, match]);
    }

    // Sorting
    switch (sortBy?.toLowerCase()) {
      case 'artist':
        sql += ' ORDER BY s.artist COLLATE NOCASE ASC, s.title COLLATE NOCASE ASC';
        break;
      case 'album':
        sql += ' ORDER BY s.album COLLATE NOCASE ASC, s.title COLLATE NOCASE ASC';
        break;
      case 'recently_added':
        sql += ' ORDER BY s.date_added DESC';
        break;
      case 'play_count':
        sql += ' ORDER BY s.play_count DESC';
        break;
      case 'title':
      default:
        sql += ' ORDER BY s.title COLLATE NOCASE ASC';
        break;
    }

    final results = await db.rawQuery(sql, args);
    return results.map((map) => Song.fromMap(map)).toList();
  }

  /// Get song by ID
  Future<Song?> getSongById(String songId) async {
    final db = await _db;
    final results = await db.rawQuery('''
      SELECT s.*, 
             CASE WHEN l.song_id IS NOT NULL THEN 1 ELSE 0 END AS is_favorite
      FROM ${DbTables.songs} s
      LEFT JOIN ${DbTables.likedSongs} l ON s.id = l.song_id
      WHERE s.id = ?
      LIMIT 1
    ''', [songId]);

    if (results.isEmpty) return null;
    return Song.fromMap(results.first);
  }

  /// Fetch liked songs
  Future<List<Song>> getLikedSongs() async {
    final db = await _db;
    final results = await db.rawQuery('''
      SELECT s.*, 1 AS is_favorite
      FROM ${DbTables.songs} s
      INNER JOIN ${DbTables.likedSongs} l ON s.id = l.song_id
      ORDER BY l.created_at DESC
    ''');
    return results.map((map) => Song.fromMap(map)).toList();
  }

  /// Toggle liked status
  Future<bool> toggleFavorite(String songId) async {
    final db = await _db;
    final existing = await db.query(
      DbTables.likedSongs,
      where: 'song_id = ?',
      whereArgs: [songId],
    );

    if (existing.isNotEmpty) {
      await db.delete(
        DbTables.likedSongs,
        where: 'song_id = ?',
        whereArgs: [songId],
      );
      return false;
    } else {
      await db.insert(
        DbTables.likedSongs,
        {
          'song_id': songId,
          'created_at': DateTime.now().millisecondsSinceEpoch,
        },
      );
      return true;
    }
  }

  /// Increment play count and update last played
  Future<void> incrementPlayCount(String songId) async {
    final db = await _db;
    await db.rawUpdate('''
      UPDATE ${DbTables.songs}
      SET play_count = play_count + 1
      WHERE id = ?
    ''', [songId]);
  }

  /// Batch insert or update scanned songs
  Future<void> upsertSongs(List<Song> songs) async {
    final db = await _db;
    await db.transaction((txn) async {
      final batch = txn.batch();
      for (final song in songs) {
        batch.insert(
          DbTables.songs,
          song.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    });
  }

  /// Get distinct artists
  Future<List<String>> getDistinctArtists() async {
    final db = await _db;
    final results = await db.rawQuery('''
      SELECT DISTINCT artist FROM ${DbTables.songs} 
      WHERE artist IS NOT NULL AND artist != ''
      ORDER BY artist COLLATE NOCASE ASC
    ''');
    return results.map((row) => row['artist'] as String).toList();
  }

  /// Get distinct albums
  Future<List<Map<String, dynamic>>> getDistinctAlbums() async {
    final db = await _db;
    return await db.rawQuery('''
      SELECT album, artist, artwork_uri, COUNT(id) as song_count 
      FROM ${DbTables.songs}
      WHERE album IS NOT NULL AND album != ''
      GROUP BY album, artist
      ORDER BY album COLLATE NOCASE ASC
    ''');
  }

  /// Get distinct genres
  Future<List<Map<String, dynamic>>> getDistinctGenres() async {
    final db = await _db;
    return await db.rawQuery('''
      SELECT genre, COUNT(id) as song_count 
      FROM ${DbTables.songs}
      WHERE genre IS NOT NULL AND genre != ''
      GROUP BY genre
      ORDER BY song_count DESC
    ''');
  }

  /// Total count of songs in database
  Future<int> getSongCount() async {
    final db = await _db;
    final result = await db.rawQuery('SELECT COUNT(id) as count FROM ${DbTables.songs}');
    return (result.first['count'] as num?)?.toInt() ?? 0;
  }
}
