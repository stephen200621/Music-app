class PlaybackSessionState {
  final String? currentSongId;
  final int positionMs;
  final int currentQueueIndex;
  final String selectedMode;
  final bool shuffleEnabled;
  final String repeatMode; // 'off', 'all', 'one'
  final int updatedAt;

  const PlaybackSessionState({
    this.currentSongId,
    this.positionMs = 0,
    this.currentQueueIndex = 0,
    this.selectedMode = 'chill',
    this.shuffleEnabled = false,
    this.repeatMode = 'all',
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': 1, // Single active session record
      'current_song_id': currentSongId,
      'position_ms': positionMs,
      'current_queue_index': currentQueueIndex,
      'selected_mode': selectedMode,
      'shuffle_enabled': shuffleEnabled ? 1 : 0,
      'repeat_mode': repeatMode,
      'updated_at': updatedAt,
    };
  }

  factory PlaybackSessionState.fromMap(Map<String, dynamic> map) {
    return PlaybackSessionState(
      currentSongId: map['current_song_id'] as String?,
      positionMs: (map['position_ms'] as num?)?.toInt() ?? 0,
      currentQueueIndex: (map['current_queue_index'] as num?)?.toInt() ?? 0,
      selectedMode: map['selected_mode'] as String? ?? 'chill',
      shuffleEnabled: (map['shuffle_enabled'] as num?) == 1,
      repeatMode: map['repeat_mode'] as String? ?? 'all',
      updatedAt: (map['updated_at'] as num?)?.toInt() ?? DateTime.now().millisecondsSinceEpoch,
    );
  }
}
