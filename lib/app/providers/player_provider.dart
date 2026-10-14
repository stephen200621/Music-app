import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../../data/models/song.dart';
import '../../data/models/play_history_item.dart';
import '../../data/repositories/music_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../services/audio/audio_player_service.dart';

class PlayerState {
  final Song? currentSong;
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final Duration bufferedPosition;
  final List<Song> queue;
  final int currentIndex;
  final bool isShuffle;
  final String repeatMode; // 'off', 'all', 'one'
  final bool isLoading;

  const PlayerState({
    this.currentSong,
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.bufferedPosition = Duration.zero,
    this.queue = const [],
    this.currentIndex = 0,
    this.isShuffle = false,
    this.repeatMode = 'all',
    this.isLoading = false,
  });

  PlayerState copyWith({
    Song? currentSong,
    bool? isPlaying,
    Duration? position,
    Duration? duration,
    Duration? bufferedPosition,
    List<Song>? queue,
    int? currentIndex,
    bool? isShuffle,
    String? repeatMode,
    bool? isLoading,
  }) {
    return PlayerState(
      currentSong: currentSong ?? this.currentSong,
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      bufferedPosition: bufferedPosition ?? this.bufferedPosition,
      queue: queue ?? this.queue,
      currentIndex: currentIndex ?? this.currentIndex,
      isShuffle: isShuffle ?? this.isShuffle,
      repeatMode: repeatMode ?? this.repeatMode,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class PlayerNotifier extends StateNotifier<PlayerState> {
  final MusicRepository _musicRepo;
  final SettingsRepository _settingsRepo;

  PlayerNotifier({
    MusicRepository? musicRepo,
    SettingsRepository? settingsRepo,
  })  : _musicRepo = musicRepo ?? MusicRepository(),
        _settingsRepo = settingsRepo ?? SettingsRepository(),
        super(const PlayerState()) {
    _bindAudioPlayerService();
  }

  void _bindAudioPlayerService() {
    try {
      final service = AudioPlayerService.instance;
      final player = service.handler.player;

      player.playerStateStream.listen((state) {
        this.state = this.state.copyWith(
              isPlaying: state.playing,
              isLoading: state.processingState == ProcessingState.loading ||
                  state.processingState == ProcessingState.buffering,
            );
      });

      player.positionStream.listen((pos) {
        this.state = this.state.copyWith(position: pos);
      });

      player.durationStream.listen((dur) {
        if (dur != null) {
          this.state = this.state.copyWith(duration: dur);
        }
      });

      player.bufferedPositionStream.listen((buf) {
        this.state = this.state.copyWith(bufferedPosition: buf);
      });

      service.handler.mediaItem.listen((item) {
        if (item != null) {
          final found = this.state.queue.firstWhere(
                (s) => s.id == item.id,
                orElse: () => Song(
                  id: item.id,
                  title: item.title,
                  artist: item.artist ?? 'Unknown Artist',
                  album: item.album ?? 'Unknown Album',
                  durationMs: item.duration?.inMilliseconds ?? 0,
                  artworkUri: item.artUri?.toString(),
                  fileUri: item.extras?['fileUri'] ?? '',
                  dateAdded: DateTime.now().millisecondsSinceEpoch,
                  lastScannedAt: DateTime.now().millisecondsSinceEpoch,
                ),
              );

          final idx = this.state.queue.indexWhere((s) => s.id == item.id);
          this.state = this.state.copyWith(
                currentSong: found,
                currentIndex: idx >= 0 ? idx : this.state.currentIndex,
                duration: Duration(milliseconds: found.durationMs),
              );
        }
      });
    } catch (_) {
      // In tests / mocks without full audio_service background init
    }
  }

  Future<void> playSong(Song song, List<Song> queue) async {
    final index = queue.indexWhere((s) => s.id == song.id);
    state = state.copyWith(
      currentSong: song,
      queue: List.from(queue),
      currentIndex: index >= 0 ? index : 0,
      duration: Duration(milliseconds: song.durationMs),
      position: Duration.zero,
      isPlaying: true,
    );

    try {
      await AudioPlayerService.instance.playSong(song, queue);
    } catch (_) {}
  }

  Future<void> togglePlayPause() async {
    final playing = !state.isPlaying;
    state = state.copyWith(isPlaying: playing);
    try {
      await AudioPlayerService.instance.togglePlayPause();
    } catch (_) {}
  }

  Future<void> seek(Duration position) async {
    state = state.copyWith(position: position);
    try {
      await AudioPlayerService.instance.seek(position);
    } catch (_) {}
  }

  Future<void> next() async {
    if (state.queue.isEmpty) return;
    int nextIdx = state.currentIndex + 1;
    if (nextIdx >= state.queue.length) {
      if (state.repeatMode == 'all') {
        nextIdx = 0;
      } else {
        return;
      }
    }
    final nextSong = state.queue[nextIdx];
    state = state.copyWith(
      currentSong: nextSong,
      currentIndex: nextIdx,
      position: Duration.zero,
      duration: Duration(milliseconds: nextSong.durationMs),
    );
    try {
      await AudioPlayerService.instance.next();
    } catch (_) {}
  }

  Future<void> previous() async {
    if (state.queue.isEmpty) return;
    if (state.position.inSeconds > 3) {
      await seek(Duration.zero);
      return;
    }
    int prevIdx = state.currentIndex - 1;
    if (prevIdx < 0) {
      prevIdx = state.queue.length - 1;
    }
    final prevSong = state.queue[prevIdx];
    state = state.copyWith(
      currentSong: prevSong,
      currentIndex: prevIdx,
      position: Duration.zero,
      duration: Duration(milliseconds: prevSong.durationMs),
    );
    try {
      await AudioPlayerService.instance.previous();
    } catch (_) {}
  }

  Future<void> playQueueIndex(int index) async {
    if (index >= 0 && index < state.queue.length) {
      final song = state.queue[index];
      state = state.copyWith(
        currentSong: song,
        currentIndex: index,
        position: Duration.zero,
        duration: Duration(milliseconds: song.durationMs),
        isPlaying: true,
      );
      try {
        await AudioPlayerService.instance.playQueueIndex(index);
      } catch (_) {}
    }
  }

  Future<void> toggleShuffle() async {
    final nextShuffle = !state.isShuffle;
    state = state.copyWith(isShuffle: nextShuffle);
    try {
      await AudioPlayerService.instance.toggleShuffle();
    } catch (_) {}
  }

  Future<void> cycleRepeatMode() async {
    String nextRepeat;
    if (state.repeatMode == 'all') {
      nextRepeat = 'one';
    } else if (state.repeatMode == 'one') {
      nextRepeat = 'off';
    } else {
      nextRepeat = 'all';
    }
    state = state.copyWith(repeatMode: nextRepeat);
    try {
      await AudioPlayerService.instance.cycleRepeatMode();
    } catch (_) {}
  }

  Future<void> toggleFavoriteCurrent() async {
    final current = state.currentSong;
    if (current == null) return;
    final isFav = await _musicRepo.toggleFavorite(current.id);
    final updated = current.copyWith(isFavorite: isFav);

    final updatedQueue = state.queue.map((s) => s.id == current.id ? updated : s).toList();
    state = state.copyWith(
      currentSong: updated,
      queue: updatedQueue,
    );
  }

  Future<void> reorderQueue(int oldIndex, int newIndex) async {
    final list = List<Song>.from(state.queue);
    if (newIndex > oldIndex) newIndex -= 1;
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);

    int newCurrentIdx = state.currentIndex;
    if (state.currentSong != null) {
      newCurrentIdx = list.indexWhere((s) => s.id == state.currentSong!.id);
    }

    state = state.copyWith(queue: list, currentIndex: newCurrentIdx);
    await _settingsRepo.saveQueue(list);
  }

  Future<void> removeFromQueue(int index) async {
    if (index < 0 || index >= state.queue.length) return;
    final list = List<Song>.from(state.queue);
    list.removeAt(index);

    int newCurrentIdx = state.currentIndex;
    if (index < state.currentIndex) {
      newCurrentIdx--;
    } else if (index == state.currentIndex) {
      if (list.isNotEmpty) {
        newCurrentIdx = newCurrentIdx.clamp(0, list.length - 1);
        final nextSong = list[newCurrentIdx];
        state = state.copyWith(currentSong: nextSong, queue: list, currentIndex: newCurrentIdx);
        await AudioPlayerService.instance.playSong(nextSong, list);
        return;
      } else {
        state = state.copyWith(queue: [], currentSong: null, isPlaying: false);
        await AudioPlayerService.instance.pause();
        return;
      }
    }

    state = state.copyWith(queue: list, currentIndex: newCurrentIdx);
    await _settingsRepo.saveQueue(list);
  }

  Future<void> addNext(Song song) async {
    final list = List<Song>.from(state.queue);
    final insertIdx = (state.currentIndex + 1).clamp(0, list.length);
    list.insert(insertIdx, song);
    state = state.copyWith(queue: list);
    await _settingsRepo.saveQueue(list);
  }

  Future<void> addToEnd(Song song) async {
    final list = List<Song>.from(state.queue)..add(song);
    state = state.copyWith(queue: list);
    await _settingsRepo.saveQueue(list);
  }

  Future<void> clearQueue() async {
    state = state.copyWith(queue: [], currentSong: null, isPlaying: false);
    try {
      await AudioPlayerService.instance.pause();
      await _settingsRepo.saveQueue([]);
    } catch (_) {}
  }

  /// Restore previous session state upon startup
  Future<void> restorePreviousSession() async {
    final session = await _settingsRepo.getPlaybackSession();
    final savedQueue = await _settingsRepo.restoreQueue();

    if (savedQueue.isNotEmpty) {
      Song? targetSong;
      int targetIdx = 0;

      if (session != null && session.currentSongId != null) {
        targetIdx = savedQueue.indexWhere((s) => s.id == session.currentSongId);
        if (targetIdx >= 0) {
          targetSong = savedQueue[targetIdx];
        }
      }

      targetSong ??= savedQueue.first;
      final pos = Duration(milliseconds: session?.positionMs ?? 0);

      state = state.copyWith(
        queue: savedQueue,
        currentIndex: targetIdx >= 0 ? targetIdx : 0,
        currentSong: targetSong,
        position: pos,
        duration: Duration(milliseconds: targetSong.durationMs),
        isShuffle: session?.shuffleEnabled ?? false,
        repeatMode: session?.repeatMode ?? 'all',
        isPlaying: false,
      );

      try {
        await AudioPlayerService.instance.handler.updateSongQueue(
          savedQueue,
          initialIndex: targetIdx >= 0 ? targetIdx : 0,
        );
        await AudioPlayerService.instance.handler.prepareSong(
          targetSong,
          autoPlay: false,
          initialPosition: pos,
        );
      } catch (_) {}
    }
  }
}

final playerProvider = StateNotifierProvider<PlayerNotifier, PlayerState>((ref) {
  return PlayerNotifier();
});
