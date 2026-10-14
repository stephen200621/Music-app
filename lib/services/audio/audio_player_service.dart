import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/play_history_item.dart';
import '../../data/models/song.dart';
import '../../data/models/playback_session_state.dart';
import '../../data/repositories/history_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/repositories/music_repository.dart';
import 'audio_player_handler.dart';

class AudioPlayerService {
  static final AudioPlayerService instance = AudioPlayerService._();
  AudioPlayerService._();

  VybeAudioHandler? _handler;
  final HistoryRepository _historyRepo = HistoryRepository();
  final SettingsRepository _settingsRepo = SettingsRepository();
  final MusicRepository _musicRepo = MusicRepository();

  // Internal playback tracking
  int _trackStartedAt = 0;
  int _lastPositionMs = 0;
  String _activeMode = 'chill';
  Timer? _positionDebounceTimer;

  void initialize(VybeAudioHandler handler) {
    _handler = handler;
    _listenToPlaybackState();
  }

  VybeAudioHandler get handler =>
      _handler ?? (throw StateError('VybeAudioHandler not initialized yet'));

  void setMode(String mode) {
    _activeMode = mode;
  }

  void _listenToPlaybackState() {
    final h = _handler;
    if (h == null) return;

    // Track position changes for history recording & session saving
    h.player.positionStream.listen((pos) {
      _lastPositionMs = pos.inMilliseconds;
      _debounceSaveSession();
    });

    // Detect track changes to record history
    h.mediaItem.listen((item) {
      if (item != null) {
        _onNewTrackStarted(item);
      }
    });
  }

  void _onNewTrackStarted(MediaItem item) {
    _trackStartedAt = DateTime.now().millisecondsSinceEpoch;
    _lastPositionMs = 0;
    _musicRepo.incrementPlayCount(item.id);
  }

  void _debounceSaveSession() {
    _positionDebounceTimer?.cancel();
    _positionDebounceTimer = Timer(const Duration(seconds: 4), () {
      final current = _handler?.currentSong;
      if (current != null) {
        _settingsRepo.savePlaybackSession(
          PlaybackSessionState(
            currentSongId: current.id,
            positionMs: _lastPositionMs,
            currentQueueIndex: _handler?.currentIndex ?? 0,
            selectedMode: _activeMode,
            shuffleEnabled: _handler?.player.shuffleModeEnabled ?? false,
            repeatMode: _handler?.player.loopMode == LoopMode.one
                ? 'one'
                : (_handler?.player.loopMode == LoopMode.all ? 'all' : 'off'),
            updatedAt: DateTime.now().millisecondsSinceEpoch,
          ),
        );
      }
    });
  }

  /// Record history when track is skipped or completed
  Future<void> recordCurrentHistory(HistoryEventType type) async {
    final song = _handler?.currentSong;
    if (song == null || _trackStartedAt == 0) return;

    final listenedMs = _lastPositionMs;

    // Only record if listened for at least minimum threshold or if skipped early
    if (listenedMs >= AppConstants.minPlaybackMsForHistory || type == HistoryEventType.skipped) {
      await _historyRepo.recordPlayEvent(
        songId: song.id,
        startedAt: _trackStartedAt,
        listenedDurationMs: listenedMs,
        totalDurationMs: song.durationMs,
        eventType: type,
        listeningMode: _activeMode,
      );
    }
  }

  // Playback Control Actions
  Future<void> play() async => await _handler?.play();
  Future<void> pause() async => await _handler?.pause();
  Future<void> togglePlayPause() async {
    if (_handler?.player.playing == true) {
      await pause();
    } else {
      await play();
    }
  }

  Future<void> seek(Duration position) async => await _handler?.seek(position);

  Future<void> next() async {
    // If skipped quickly, mark as skip
    if (_lastPositionMs < AppConstants.skipThresholdMs && _lastPositionMs > 1000) {
      await recordCurrentHistory(HistoryEventType.skipped);
    } else {
      await recordCurrentHistory(HistoryEventType.played);
    }
    await _handler?.skipToNext();
  }

  Future<void> previous() async {
    await _handler?.skipToPrevious();
  }

  Future<void> playSong(Song song, List<Song> queue) async {
    final index = queue.indexWhere((s) => s.id == song.id);
    await _handler?.updateSongQueue(queue, initialIndex: index >= 0 ? index : 0);
    await _handler?.prepareSong(song, autoPlay: true);
    await _settingsRepo.saveQueue(queue);
  }

  Future<void> playQueueIndex(int index) async {
    await _handler?.skipToQueueItem(index);
  }

  Future<void> toggleShuffle() async {
    final current = _handler?.player.shuffleModeEnabled ?? false;
    await _handler?.setShuffleMode(
      !current ? AudioServiceShuffleMode.all : AudioServiceShuffleMode.none,
    );
  }

  Future<void> cycleRepeatMode() async {
    final current = _handler?.player.loopMode ?? LoopMode.all;
    if (current == LoopMode.all) {
      await _handler?.setRepeatMode(AudioServiceRepeatMode.one);
    } else if (current == LoopMode.one) {
      await _handler?.setRepeatMode(AudioServiceRepeatMode.none);
    } else {
      await _handler?.setRepeatMode(AudioServiceRepeatMode.all);
    }
  }

  void dispose() {
    _positionDebounceTimer?.cancel();
  }
}
