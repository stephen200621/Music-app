class DbTables {
  DbTables._();

  static const String songs = 'songs';
  static const String playlists = 'playlists';
  static const String playlistSongs = 'playlist_songs';
  static const String likedSongs = 'liked_songs';
  static const String playHistory = 'play_history';
  static const String listeningPreferences = 'listening_preferences';
  static const String appSettings = 'app_settings';
  static const String playbackSession = 'playback_session';
  static const String playbackQueue = 'playback_queue';

  static const String createSongsTable = '''
    CREATE TABLE $songs (
      id TEXT PRIMARY KEY,
      media_store_id TEXT,
      file_uri TEXT NOT NULL UNIQUE,
      title TEXT NOT NULL,
      artist TEXT,
      album TEXT,
      genre TEXT,
      duration_ms INTEGER,
      artwork_uri TEXT,
      date_added INTEGER,
      last_scanned_at INTEGER,
      play_count INTEGER DEFAULT 0,
      energy REAL DEFAULT 0.5
    );
  ''';

  static const String createPlaylistsTable = '''
    CREATE TABLE $playlists (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      created_at INTEGER,
      updated_at INTEGER,
      sort_order INTEGER DEFAULT 0
    );
  ''';

  static const String createPlaylistSongsTable = '''
    CREATE TABLE $playlistSongs (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      playlist_id TEXT NOT NULL,
      song_id TEXT NOT NULL,
      position INTEGER NOT NULL,
      added_at INTEGER NOT NULL,
      FOREIGN KEY (playlist_id) REFERENCES $playlists(id) ON DELETE CASCADE,
      FOREIGN KEY (song_id) REFERENCES $songs(id) ON DELETE CASCADE,
      UNIQUE (playlist_id, song_id)
    );
  ''';

  static const String createLikedSongsTable = '''
    CREATE TABLE $likedSongs (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      song_id TEXT NOT NULL UNIQUE,
      created_at INTEGER NOT NULL,
      FOREIGN KEY (song_id) REFERENCES $songs(id) ON DELETE CASCADE
    );
  ''';

  static const String createPlayHistoryTable = '''
    CREATE TABLE $playHistory (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      song_id TEXT NOT NULL,
      started_at INTEGER NOT NULL,
      last_updated_at INTEGER NOT NULL,
      listened_duration_ms INTEGER NOT NULL,
      completion_percentage INTEGER NOT NULL,
      event_type TEXT NOT NULL,
      listening_mode TEXT DEFAULT 'chill',
      FOREIGN KEY (song_id) REFERENCES $songs(id) ON DELETE CASCADE
    );
  ''';

  static const String createListeningPreferencesTable = '''
    CREATE TABLE $listeningPreferences (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      genre TEXT,
      artist TEXT,
      preference_score REAL DEFAULT 0.0,
      updated_at INTEGER NOT NULL
    );
  ''';

  static const String createAppSettingsTable = '''
    CREATE TABLE $appSettings (
      key TEXT PRIMARY KEY,
      value TEXT NOT NULL,
      updated_at INTEGER NOT NULL
    );
  ''';

  static const String createPlaybackSessionTable = '''
    CREATE TABLE $playbackSession (
      id INTEGER PRIMARY KEY,
      current_song_id TEXT,
      position_ms INTEGER,
      current_queue_index INTEGER,
      selected_mode TEXT,
      shuffle_enabled INTEGER,
      repeat_mode TEXT,
      updated_at INTEGER NOT NULL
    );
  ''';

  static const String createPlaybackQueueTable = '''
    CREATE TABLE $playbackQueue (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      song_id TEXT NOT NULL,
      position INTEGER NOT NULL,
      source_type TEXT,
      source_id TEXT,
      FOREIGN KEY (song_id) REFERENCES $songs(id) ON DELETE CASCADE
    );
  ''';

  // Indexes
  static const List<String> createIndexes = [
    'CREATE INDEX idx_songs_title ON $songs(title);',
    'CREATE INDEX idx_songs_artist ON $songs(artist);',
    'CREATE INDEX idx_history_song_id ON $playHistory(song_id);',
    'CREATE INDEX idx_history_started_at ON $playHistory(started_at DESC);',
    'CREATE INDEX idx_playlist_songs_playlist ON $playlistSongs(playlist_id, position);',
    'CREATE INDEX idx_playback_queue_pos ON $playbackQueue(position ASC);',
  ];
}
