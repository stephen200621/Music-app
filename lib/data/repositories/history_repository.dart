import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../database/app_database.dart';
import '../database/tables.dart';
import '../models/play_history_item.dart';

class HistoryRepository {
  final AppDatabase _dbProvider;

  HistoryRepository({AppDatabase? dbProvider})
      : _dbProvider = dbProvider ?? AppDatabase.instance;

  Future<Database> get _db => _dbProvider.database;

  /// Fetch history items sorted newest to oldest, joined with song metadata
  Future<List<PlayHistoryItem>> getHistory({int limit = 100}) async {
    final db = await _db;
    final results = await db.rawQuery('''
      SELECT h.*, s.title, s.artist, s.artwork_uri
      FROM ${DbTables.playHistory} h
      LEFT JOIN ${DbTables.songs} s ON h.song_id = s.id
      ORDER BY h.started_at DESC
      LIMIT ?
    ''', [limit]);

    return results.map((map) => PlayHistoryItem.fromMap(map)).toList();
  }

  /// Record a play or skip event
  Future<int> recordPlayEvent({
    required String songId,
    required int startedAt,
    required int listenedDurationMs,
    required int totalDurationMs,
    required HistoryEventType eventType,
    required String listeningMode,
  }) async {
    final db = await _db;
    final int completion = totalDurationMs > 0
        ? ((listenedDurationMs / totalDurationMs) * 100).clamp(0, 100).round()
        : 0;

    return await db.insert(
      DbTables.playHistory,
      {
        'song_id': songId,
        'started_at': startedAt,
        'last_updated_at': DateTime.now().millisecondsSinceEpoch,
        'listened_duration_ms': listenedDurationMs,
        'completion_percentage': completion,
        'event_type': eventType.name,
        'listening_mode': listeningMode,
      },
    );
  }

  /// Remove a single history item by ID
  Future<void> removeHistoryItem(int id) async {
    final db = await _db;
    await db.delete(
      DbTables.playHistory,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Clear entire history
  Future<void> clearAllHistory() async {
    final db = await _db;
    await db.delete(DbTables.playHistory);
  }

  /// Export listening history as JSON string for privacy and backups
  Future<String> exportHistoryJson() async {
    final historyList = await getHistory(limit: 5000);
    final listMaps = historyList.map((item) => item.toMap()).toList();
    return const JsonEncoder.withIndent('  ').convert({
      'export_timestamp': DateTime.now().toIso8601String(),
      'item_count': listMaps.length,
      'history': listMaps,
    });
  }

  /// Get total plays count for a specific song
  Future<int> getSongPlayCount(String songId) async {
    final db = await _db;
    final res = await db.rawQuery('''
      SELECT COUNT(id) as count FROM ${DbTables.playHistory}
      WHERE song_id = ? AND event_type IN ('played', 'completed')
    ''', [songId]);
    return (res.first['count'] as num?)?.toInt() ?? 0;
  }

  /// Get recent skip count for a specific song
  Future<int> getSongSkipCount(String songId) async {
    final db = await _db;
    final res = await db.rawQuery('''
      SELECT COUNT(id) as count FROM ${DbTables.playHistory}
      WHERE song_id = ? AND event_type = 'skipped'
    ''', [songId]);
    return (res.first['count'] as num?)?.toInt() ?? 0;
  }
}
