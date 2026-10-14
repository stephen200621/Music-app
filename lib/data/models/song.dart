class Song {
  final String id;
  final String? mediaStoreId;
  final String fileUri;
  final String title;
  final String artist;
  final String album;
  final String genre;
  final int durationMs;
  final String? artworkUri;
  final int dateAdded;
  final int lastScannedAt;
  final bool isFavorite;
  final int playCount;
  final double energy; // Estimated energy level 0.0 to 1.0

  const Song({
    required this.id,
    this.mediaStoreId,
    required this.fileUri,
    required this.title,
    this.artist = 'Unknown Artist',
    this.album = 'Unknown Album',
    this.genre = 'Unknown Genre',
    this.durationMs = 0,
    this.artworkUri,
    required this.dateAdded,
    required this.lastScannedAt,
    this.isFavorite = false,
    this.playCount = 0,
    this.energy = 0.5,
  });

  Song copyWith({
    String? id,
    String? mediaStoreId,
    String? fileUri,
    String? title,
    String? artist,
    String? album,
    String? genre,
    int? durationMs,
    String? artworkUri,
    int? dateAdded,
    int? lastScannedAt,
    bool? isFavorite,
    int? playCount,
    double? energy,
  }) {
    return Song(
      id: id ?? this.id,
      mediaStoreId: mediaStoreId ?? this.mediaStoreId,
      fileUri: fileUri ?? this.fileUri,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      genre: genre ?? this.genre,
      durationMs: durationMs ?? this.durationMs,
      artworkUri: artworkUri ?? this.artworkUri,
      dateAdded: dateAdded ?? this.dateAdded,
      lastScannedAt: lastScannedAt ?? this.lastScannedAt,
      isFavorite: isFavorite ?? this.isFavorite,
      playCount: playCount ?? this.playCount,
      energy: energy ?? this.energy,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'media_store_id': mediaStoreId,
      'file_uri': fileUri,
      'title': title,
      'artist': artist,
      'album': album,
      'genre': genre,
      'duration_ms': durationMs,
      'artwork_uri': artworkUri,
      'date_added': dateAdded,
      'last_scanned_at': lastScannedAt,
      'play_count': playCount,
      'energy': energy,
    };
  }

  factory Song.fromMap(Map<String, dynamic> map, {bool isFavorite = false}) {
    return Song(
      id: map['id'] as String,
      mediaStoreId: map['media_store_id'] as String?,
      fileUri: map['file_uri'] as String,
      title: map['title'] as String? ?? 'Untitled Track',
      artist: (map['artist'] as String?)?.isNotEmpty == true
          ? map['artist'] as String
          : 'Unknown Artist',
      album: (map['album'] as String?)?.isNotEmpty == true
          ? map['album'] as String
          : 'Unknown Album',
      genre: (map['genre'] as String?)?.isNotEmpty == true
          ? map['genre'] as String
          : 'Unknown Genre',
      durationMs: (map['duration_ms'] as num?)?.toInt() ?? 0,
      artworkUri: map['artwork_uri'] as String?,
      dateAdded: (map['date_added'] as num?)?.toInt() ?? 0,
      lastScannedAt: (map['last_scanned_at'] as num?)?.toInt() ?? 0,
      isFavorite: isFavorite || ((map['is_favorite'] as int?) == 1),
      playCount: (map['play_count'] as num?)?.toInt() ?? 0,
      energy: (map['energy'] as num?)?.toDouble() ?? 0.5,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Song && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
