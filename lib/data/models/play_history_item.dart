enum HistoryEventType {
  played,
  completed,
  skipped,
  interrupted;

  static HistoryEventType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'completed':
        return HistoryEventType.completed;
      case 'skipped':
        return HistoryEventType.skipped;
      case 'interrupted':
        return HistoryEventType.interrupted;
      default:
        return HistoryEventType.played;
    }
  }
}

class PlayHistoryItem {
  final int id;
  final String songId;
  final String? songTitle;
  final String? songArtist;
  final String? artworkUri;
  final int startedAt;
  final int lastUpdatedAt;
  final int listenedDurationMs;
  final int completionPercentage;
  final HistoryEventType eventType;
  final String listeningMode;

  const PlayHistoryItem({
    required this.id,
    required this.songId,
    this.songTitle,
    this.songArtist,
    this.artworkUri,
    required this.startedAt,
    required this.lastUpdatedAt,
    required this.listenedDurationMs,
    required this.completionPercentage,
    required this.eventType,
    this.listeningMode = 'chill',
  });

  Map<String, dynamic> toMap() {
    return {
      if (id > 0) 'id': id,
      'song_id': songId,
      'started_at': startedAt,
      'last_updated_at': lastUpdatedAt,
      'listened_duration_ms': listenedDurationMs,
      'completion_percentage': completionPercentage,
      'event_type': eventType.name,
      'listening_mode': listeningMode,
    };
  }

  factory PlayHistoryItem.fromMap(Map<String, dynamic> map) {
    return PlayHistoryItem(
      id: (map['id'] as num?)?.toInt() ?? 0,
      songId: map['song_id'] as String,
      songTitle: map['title'] as String?,
      songArtist: map['artist'] as String?,
      artworkUri: map['artwork_uri'] as String?,
      startedAt: (map['started_at'] as num).toInt(),
      lastUpdatedAt: (map['last_updated_at'] as num).toInt(),
      listenedDurationMs: (map['listened_duration_ms'] as num).toInt(),
      completionPercentage: (map['completion_percentage'] as num).toInt(),
      eventType: HistoryEventType.fromString(map['event_type'] as String? ?? 'played'),
      listeningMode: map['listening_mode'] as String? ?? 'chill',
    );
  }
}
