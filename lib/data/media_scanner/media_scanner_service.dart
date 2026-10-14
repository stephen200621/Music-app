import 'dart:io';
import 'package:on_audio_query/on_audio_query.dart';
import '../../core/permissions/permission_service.dart';
import '../models/song.dart';
import '../repositories/music_repository.dart';

class MediaScannerService {
  final OnAudioQuery _audioQuery;
  final MusicRepository _musicRepository;

  MediaScannerService({
    OnAudioQuery? audioQuery,
    MusicRepository? musicRepository,
  })  : _audioQuery = audioQuery ?? OnAudioQuery(),
        _musicRepository = musicRepository ?? MusicRepository();

  /// Scans device MediaStore for audio files and updates SQLite database
  Future<List<Song>> scanDeviceMedia() async {
    final hasPermission = await PermissionService.instance.hasAudioPermission();
    if (!hasPermission) {
      final status = await PermissionService.instance.requestAudioPermissions();
      if (status != AudioPermissionStatus.granted) {
        return await _checkAndSeedFallbackIfEmpty();
      }
    }

    try {
      if (Platform.isAndroid || Platform.isIOS) {
        final querySongs = await _audioQuery.querySongs(
          sortType: SongSortType.TITLE,
          orderType: OrderType.ASC_OR_SMALLER,
          uriType: UriType.EXTERNAL,
          ignoreCase: true,
        );

        if (querySongs.isNotEmpty) {
          final now = DateTime.now().millisecondsSinceEpoch;
          final List<Song> scanned = [];

          for (final item in querySongs) {
            // Filter out voice notes, rings, and files under 10 seconds
            if ((item.duration ?? 0) < 10000) continue;

            final song = Song(
              id: 'device_${item.id}',
              mediaStoreId: item.id.toString(),
              fileUri: item.uri ?? item.data,
              title: item.title.trim().isNotEmpty ? item.title.trim() : 'Unknown Title',
              artist: (item.artist != null && item.artist != '<unknown>')
                  ? item.artist!
                  : 'Unknown Artist',
              album: (item.album != null && item.album != '<unknown>')
                  ? item.album!
                  : 'Unknown Album',
              genre: item.genre ?? _inferGenre(item.title, item.artist),
              durationMs: item.duration ?? 0,
              artworkUri: null, // Artwork loaded via queryArtwork on demand
              dateAdded: (item.dateAdded ?? (now ~/ 1000)) * 1000,
              lastScannedAt: now,
              energy: _estimateEnergy(item.title, item.genre),
            );
            scanned.add(song);
          }

          if (scanned.isNotEmpty) {
            await _musicRepository.upsertSongs(scanned);
            return await _musicRepository.getAllSongs();
          }
        }
      }
    } catch (e) {
      // Fall through to fallback
    }

    return await _checkAndSeedFallbackIfEmpty();
  }

  /// Ensures new users have instant high-fidelity music experience even without local mp3 files
  Future<List<Song>> _checkAndSeedFallbackIfEmpty() async {
    final count = await _musicRepository.getSongCount();
    if (count == 0) {
      final sampleSongs = _generateHighQualityDemoLibrary();
      await _musicRepository.upsertSongs(sampleSongs);
      return sampleSongs;
    }
    return await _musicRepository.getAllSongs();
  }

  static double _estimateEnergy(String title, String? genre) {
    final lower = '$title ${genre ?? ''}'.toLowerCase();
    if (lower.contains('workout') || lower.contains('edm') || lower.contains('rock') || lower.contains('hyper')) {
      return 0.92;
    }
    if (lower.contains('party') || lower.contains('dance') || lower.contains('beat')) {
      return 0.85;
    }
    if (lower.contains('chill') || lower.contains('ambient') || lower.contains('lofi') || lower.contains('acoustic')) {
      return 0.28;
    }
    if (lower.contains('sleep') || lower.contains('rain') || lower.contains('calm') || lower.contains('piano')) {
      return 0.15;
    }
    return 0.55;
  }

  static String _inferGenre(String title, String? artist) {
    final lower = '$title ${artist ?? ''}'.toLowerCase();
    if (lower.contains('chill') || lower.contains('lo-fi')) return 'Lo-Fi / Chill';
    if (lower.contains('synth') || lower.contains('cyber')) return 'Synthwave';
    if (lower.contains('beat') || lower.contains('trap')) return 'Hip-Hop';
    if (lower.contains('ambient')) return 'Ambient';
    return 'Electronic';
  }

  /// Built-in rich library with varied genres, moods, and energy profiles
  static List<Song> _generateHighQualityDemoLibrary() {
    final now = DateTime.now().millisecondsSinceEpoch;
    return [
      Song(
        id: 'vybe_track_01',
        title: 'Cyberpunk Skyline',
        artist: 'Kavinsky & Neon Dreams',
        album: 'Neo Tokyo 2099',
        genre: 'Synthwave',
        durationMs: 228000, // 3:48
        fileUri: 'asset:///assets/audio/synthwave_dream.mp3',
        artworkUri: 'https://images.unsplash.com/photo-1508700115892-45ecd05ae2ad?w=600&auto=format&fit=crop&q=80',
        dateAdded: now - 86400000 * 2,
        lastScannedAt: now,
        isFavorite: true,
        playCount: 14,
        energy: 0.88,
      ),
      Song(
        id: 'vybe_track_02',
        title: 'Midnight Rain Lofi',
        artist: 'Aura Chill',
        album: 'Coffee & Late Thoughts',
        genre: 'Lo-Fi / Chill',
        durationMs: 174000, // 2:54
        fileUri: 'asset:///assets/audio/midnight_rain.mp3',
        artworkUri: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=600&auto=format&fit=crop&q=80',
        dateAdded: now - 86400000 * 5,
        lastScannedAt: now,
        isFavorite: true,
        playCount: 22,
        energy: 0.25,
      ),
      Song(
        id: 'vybe_track_03',
        title: 'Quantum Velocity',
        artist: 'Overdrive Protocol',
        album: 'Hyperdrive Ignition',
        genre: 'Electronic / Bass',
        durationMs: 202000, // 3:22
        fileUri: 'asset:///assets/audio/quantum_velocity.mp3',
        artworkUri: 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=600&auto=format&fit=crop&q=80',
        dateAdded: now - 86400000 * 1,
        lastScannedAt: now,
        isFavorite: false,
        playCount: 9,
        energy: 0.95,
      ),
      Song(
        id: 'vybe_track_04',
        title: 'Deep Focus Flow',
        artist: 'Neural Calm',
        album: 'Alpha Waves 432Hz',
        genre: 'Ambient / Focus',
        durationMs: 312000, // 5:12
        fileUri: 'asset:///assets/audio/deep_focus.mp3',
        artworkUri: 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=600&auto=format&fit=crop&q=80',
        dateAdded: now - 86400000 * 7,
        lastScannedAt: now,
        isFavorite: false,
        playCount: 18,
        energy: 0.32,
      ),
      Song(
        id: 'vybe_track_05',
        title: 'Starlight Lullaby',
        artist: 'Celestial Echoes',
        album: 'Sleep In Orbit',
        genre: 'Sleep / Ambient',
        durationMs: 284000, // 4:44
        fileUri: 'asset:///assets/audio/starlight_lullaby.mp3',
        artworkUri: 'https://images.unsplash.com/photo-1446776811953-b23d57bd21aa?w=600&auto=format&fit=crop&q=80',
        dateAdded: now - 86400000 * 3,
        lastScannedAt: now,
        isFavorite: true,
        playCount: 30,
        energy: 0.12,
      ),
      Song(
        id: 'vybe_track_06',
        title: 'Club Genesis VIP',
        artist: 'Solar Pulse',
        album: 'Festival Anthems',
        genre: 'EDM / Dance',
        durationMs: 198000, // 3:18
        fileUri: 'asset:///assets/audio/club_genesis.mp3',
        artworkUri: 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=600&auto=format&fit=crop&q=80',
        dateAdded: now - 86400000 * 4,
        lastScannedAt: now,
        isFavorite: false,
        playCount: 11,
        energy: 0.94,
      ),
      Song(
        id: 'vybe_track_07',
        title: 'Acoustic Solitude',
        artist: 'Julian Croft',
        album: 'Wooden Strings',
        genre: 'Acoustic / Indie',
        durationMs: 245000, // 4:05
        fileUri: 'asset:///assets/audio/acoustic_solitude.mp3',
        artworkUri: 'https://images.unsplash.com/photo-1510915361894-db8b60106cb1?w=600&auto=format&fit=crop&q=80',
        dateAdded: now - 86400000 * 6,
        lastScannedAt: now,
        isFavorite: true,
        playCount: 15,
        energy: 0.35,
      ),
      Song(
        id: 'vybe_track_08',
        title: 'Retro Sunset Boulevard',
        artist: 'Miami Drift 84',
        album: 'Chrome Horizon',
        genre: 'Synthwave',
        durationMs: 216000, // 3:36
        fileUri: 'asset:///assets/audio/retro_sunset.mp3',
        artworkUri: 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=600&auto=format&fit=crop&q=80',
        dateAdded: now - 86400000 * 8,
        lastScannedAt: now,
        isFavorite: false,
        playCount: 8,
        energy: 0.72,
      ),
    ];
  }
}
