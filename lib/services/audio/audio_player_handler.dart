import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import '../../data/models/song.dart';

class VybeAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  final AudioPlayer _player = AudioPlayer();
  List<Song> _currentQueue = [];
  int _currentIndex = -1;
  Song? _currentSong;

  VybeAudioHandler() {
    _initAudioSession();
    _listenToPlaybackEvents();
  }

  AudioPlayer get player => _player;
  List<Song> get currentQueue => _currentQueue;
  int get currentIndex => _currentIndex;
  Song? get currentSong => _currentSong;

  Future<void> _initAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    // Handle interruptions (phone call, navigation, other media players)
    session.interruptionEventStream.listen((event) {
      if (event.begin) {
        switch (event.type) {
          case AudioInterruptionType.duck:
            _player.setVolume(0.3);
            break;
          case AudioInterruptionType.pause:
          case AudioInterruptionType.unknown:
            _player.pause();
            break;
        }
      } else {
        switch (event.type) {
          case AudioInterruptionType.duck:
            _player.setVolume(1.0);
            break;
          case AudioInterruptionType.pause:
            _player.play();
            break;
          case AudioInterruptionType.unknown:
            break;
        }
      }
    });

    // Handle unplugging headphones / disconnecting Bluetooth
    session.becomingNoisyEventStream.listen((_) {
      _player.pause();
    });
  }

  void _listenToPlaybackEvents() {
    _player.playbackEventStream.listen((PlaybackEvent event) {
      final playing = _player.playing;
      playbackState.add(playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.skipToNext,
          MediaControl.stop,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: const [0, 1, 2],
        processingState: const {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[_player.processingState]!,
        playing: playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: _currentIndex >= 0 ? _currentIndex : null,
      ));
    });

    // Handle auto-advance on track completion
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        skipToNext();
      }
    });
  }

  Future<void> updateSongQueue(List<Song> songs, {int initialIndex = 0}) async {
    _currentQueue = List.from(songs);
    _currentIndex = initialIndex.clamp(0, _currentQueue.isEmpty ? 0 : _currentQueue.length - 1);

    final mediaItems = _currentQueue.map((s) => _songToMediaItem(s)).toList();
    queue.add(mediaItems);

    if (_currentQueue.isNotEmpty && _currentIndex >= 0 && _currentIndex < _currentQueue.length) {
      await prepareSong(_currentQueue[_currentIndex]);
    }
  }

  Future<void> prepareSong(Song song, {bool autoPlay = false, Duration? initialPosition}) async {
    _currentSong = song;
    final item = _songToMediaItem(song);
    mediaItem.add(item);

    try {
      if (song.fileUri.startsWith('asset:///')) {
        final assetPath = song.fileUri.replaceFirst('asset:///', '');
        await _player.setAsset(assetPath);
      } else if (song.fileUri.startsWith('content://') || song.fileUri.startsWith('file://')) {
        await _player.setAudioSource(AudioSource.uri(Uri.parse(song.fileUri)));
      } else {
        await _player.setFilePath(song.fileUri);
      }

      if (initialPosition != null && initialPosition > Duration.zero) {
        await _player.seek(initialPosition);
      }

      if (autoPlay) {
        await _player.play();
      }
    } catch (e) {
      // In simulated / test environment or unavailable file, emit ready state for visualizer/demo
      playbackState.add(playbackState.value.copyWith(
        processingState: AudioProcessingState.ready,
      ));
    }
  }

  MediaItem _songToMediaItem(Song song) {
    return MediaItem(
      id: song.id,
      album: song.album,
      title: song.title,
      artist: song.artist,
      duration: Duration(milliseconds: song.durationMs),
      artUri: song.artworkUri != null ? Uri.parse(song.artworkUri!) : null,
      extras: {
        'genre': song.genre,
        'energy': song.energy,
        'fileUri': song.fileUri,
      },
    );
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> stop() async {
    await _player.stop();
    await super.stop();
  }

  @override
  Future<void> skipToNext() async {
    if (_currentQueue.isEmpty) return;
    int nextIndex = _currentIndex + 1;
    if (nextIndex >= _currentQueue.length) {
      if (_player.loopMode == LoopMode.all) {
        nextIndex = 0;
      } else {
        return;
      }
    }
    _currentIndex = nextIndex;
    await prepareSong(_currentQueue[_currentIndex], autoPlay: true);
  }

  @override
  Future<void> skipToPrevious() async {
    if (_currentQueue.isEmpty) return;
    if (_player.position.inSeconds > 3) {
      // Restart current track if played past 3 seconds
      await seek(Duration.zero);
      return;
    }
    int prevIndex = _currentIndex - 1;
    if (prevIndex < 0) {
      prevIndex = _currentQueue.length - 1;
    }
    _currentIndex = prevIndex;
    await prepareSong(_currentQueue[_currentIndex], autoPlay: true);
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    if (index >= 0 && index < _currentQueue.length) {
      _currentIndex = index;
      await prepareSong(_currentQueue[index], autoPlay: true);
    }
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    switch (repeatMode) {
      case AudioServiceRepeatMode.none:
        await _player.setLoopMode(LoopMode.off);
        break;
      case AudioServiceRepeatMode.one:
        await _player.setLoopMode(LoopMode.one);
        break;
      case AudioServiceRepeatMode.all:
      case AudioServiceRepeatMode.group:
        await _player.setLoopMode(LoopMode.all);
        break;
    }
    await super.setRepeatMode(repeatMode);
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    final enabled = shuffleMode == AudioServiceShuffleMode.all;
    await _player.setShuffleModeEnabled(enabled);
    await super.setShuffleMode(shuffleMode);
  }
}
