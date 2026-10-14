import 'package:sqflite/sqflite.dart';
import '../database/app_database.dart';
import '../database/tables.dart';
import '../models/playback_session_state.dart';
import '../models/song.dart';

class SettingsRepository {
  final AppDatabase _dbProvider;

  SettingsRepository({AppDatabase? dbProvider})
      : _dbProvider = dbProvider ?? AppDatabase.instance;

  Future<Database> get _db => _dbProvider.database;

  /// Get setting by key with fallback
  Future<String?> getSetting(String key) async {
    final db = await _db;
    final results = await db.query(
      DbTables.appSettings,
      columns: ['value'],
      where: 'key = ?',
      whereArgs: [key],
    );
    if (results.isEmpty) return null;
    return results.first['value'] as String?;
  }

  /// Set setting key-value
  Future<void> setSetting(String key, String value) async {
    final db = await _db;
    await db.insert(
      DbTables.appSettings,
      {
        'key': key,
        'value': value,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Save playback session state
  Future<void> savePlaybackSession(PlaybackSessionState session) async {
    final db = await _db;
    await db.insert(
      DbTables.playbackSession,
      session.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Restore last playback session state
  Future<PlaybackSessionState?> getPlaybackSession() async {
    final db = await _db;
    final results = await db.query(
      DbTables.playbackSession,
      where: 'id = ?',
      whereArgs: [1],
    );
    if (results.isEmpty) return null;
    return PlaybackSessionState.fromMap(results.first);
  }

  /// Persist current queue to database
  Future<void> saveQueue(List<Song> queue) async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.delete(DbTables.playbackQueue);
      final batch = txn.batch();
      for (int i = 0; i < queue.length; i++) {
        batch.insert(DbTables.playbackQueue, {
          'song_id': queue[i].id,
          'position': i,
          'source_type': 'queue',
          'source_id': null,
        });
      }
      await batch.commit(noResult: true);
    });
  }

  /// Restore saved queue from database
  Future<List<Song>> restoreQueue() async {
    final db = await _db;
    final results = await db.rawQuery('''
      SELECT s.*, 
             CASE WHEN l.song_id IS NOT NULL THEN 1 ELSE 0 END AS is_favorite
      FROM ${DbTables.playbackQueue} q
      INNER JOIN ${DbTables.songs} s ON q.song_id = s.id
      LEFT JOIN ${DbTables.likedSongs} l ON s.id = l.song_id
      ORDER BY q.position ASC
    ''');
    return results.map((map) => Song.fromMap(map)).toList();
  }
}
