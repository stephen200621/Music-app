import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/playlist.dart';
import '../../data/models/song.dart';
import '../../data/media_scanner/media_scanner_service.dart';
import '../../data/repositories/music_repository.dart';
import '../../data/repositories/playlist_repository.dart';

class LibraryState {
  final List<Song> songs;
  final List<Map<String, dynamic>> albums;
  final List<String> artists;
  final List<Map<String, dynamic>> genres;
  final List<Playlist> playlists;
  final List<Song> likedSongs;
  final String searchQuery;
  final String sortBy;
  final bool isScanning;

  const LibraryState({
    this.songs = const [],
    this.albums = const [],
    this.artists = const [],
    this.genres = const [],
    this.playlists = const [],
    this.likedSongs = const [],
    this.searchQuery = '',
    this.sortBy = 'title',
    this.isScanning = false,
  });

  LibraryState copyWith({
    List<Song>? songs,
    List<Map<String, dynamic>>? albums,
    List<String>? artists,
    List<Map<String, dynamic>>? genres,
    List<Playlist>? playlists,
    List<Song>? likedSongs,
    String? searchQuery,
    String? sortBy,
    bool? isScanning,
  }) {
    return LibraryState(
      songs: songs ?? this.songs,
      albums: albums ?? this.albums,
      artists: artists ?? this.artists,
      genres: genres ?? this.genres,
      playlists: playlists ?? this.playlists,
      likedSongs: likedSongs ?? this.likedSongs,
      searchQuery: searchQuery ?? this.searchQuery,
      sortBy: sortBy ?? this.sortBy,
      isScanning: isScanning ?? this.isScanning,
    );
  }
}

class LibraryNotifier extends StateNotifier<LibraryState> {
  final MediaScannerService _scanner;
  final MusicRepository _musicRepo;
  final PlaylistRepository _playlistRepo;

  LibraryNotifier({
    MediaScannerService? scanner,
    MusicRepository? musicRepo,
    PlaylistRepository? playlistRepo,
  })  : _scanner = scanner ?? MediaScannerService(),
        _musicRepo = musicRepo ?? MusicRepository(),
        _playlistRepo = playlistRepo ?? PlaylistRepository(),
        super(const LibraryState()) {
    refreshLibrary();
  }

  Future<void> scanLibrary() async {
    state = state.copyWith(isScanning: true);
    await _scanner.scanDeviceMedia();
    await refreshLibrary();
    state = state.copyWith(isScanning: false);
  }

  Future<void> refreshLibrary() async {
    final songs = await _musicRepo.getAllSongs(
      query: state.searchQuery,
      sortBy: state.sortBy,
    );
    final albums = await _musicRepo.getDistinctAlbums();
    final artists = await _musicRepo.getDistinctArtists();
    final genres = await _musicRepo.getDistinctGenres();
    final playlists = await _playlistRepo.getAllPlaylists();
    final liked = await _musicRepo.getLikedSongs();

    state = state.copyWith(
      songs: songs,
      albums: albums,
      artists: artists,
      genres: genres,
      playlists: playlists,
      likedSongs: liked,
    );
  }

  Future<void> setSearchQuery(String query) async {
    state = state.copyWith(searchQuery: query);
    final filtered = await _musicRepo.getAllSongs(
      query: query,
      sortBy: state.sortBy,
    );
    state = state.copyWith(songs: filtered);
  }

  Future<void> setSortBy(String sortBy) async {
    state = state.copyWith(sortBy: sortBy);
    await refreshLibrary();
  }

  Future<void> createPlaylist(String name) async {
    await _playlistRepo.createPlaylist(name);
    final playlists = await _playlistRepo.getAllPlaylists();
    state = state.copyWith(playlists: playlists);
  }

  Future<void> deletePlaylist(String playlistId) async {
    await _playlistRepo.deletePlaylist(playlistId);
    final playlists = await _playlistRepo.getAllPlaylists();
    state = state.copyWith(playlists: playlists);
  }

  Future<void> addSongToPlaylist(String playlistId, String songId) async {
    await _playlistRepo.addSongToPlaylist(playlistId, songId);
    final playlists = await _playlistRepo.getAllPlaylists();
    state = state.copyWith(playlists: playlists);
  }

  Future<void> toggleFavorite(String songId) async {
    await _musicRepo.toggleFavorite(songId);
    await refreshLibrary();
  }
}

final libraryProvider = StateNotifierProvider<LibraryNotifier, LibraryState>((ref) {
  return LibraryNotifier();
});
