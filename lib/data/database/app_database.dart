import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../core/constants/app_constants.dart';
import 'tables.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();
  static Database? _database;

  AppDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(AppConstants.dbName);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _createDB,
      onConfigure: _configureDB,
    );
  }

  Future<void> _configureDB(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute(DbTables.createSongsTable);
    await db.execute(DbTables.createPlaylistsTable);
    await db.execute(DbTables.createPlaylistSongsTable);
    await db.execute(DbTables.createLikedSongsTable);
    await db.execute(DbTables.createPlayHistoryTable);
    await db.execute(DbTables.createListeningPreferencesTable);
    await db.execute(DbTables.createAppSettingsTable);
    await db.execute(DbTables.createPlaybackSessionTable);
    await db.execute(DbTables.createPlaybackQueueTable);

    for (final indexSql in DbTables.createIndexes) {
      await db.execute(indexSql);
    }
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
