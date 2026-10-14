import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/providers/library_provider.dart';
import '../../../app/providers/player_provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/utils/time_formatter.dart';
import '../../../data/models/song.dart';
import '../../../shared_widgets/custom_icon_button.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final libraryState = ref.watch(libraryProvider);

    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      appBar: AppBar(
        title: Text('Music Library', style: AppTypography.screenTitle),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort_rounded, color: AppColors.secondaryText),
            tooltip: 'Sort By',
            onSelected: (sort) {
              ref.read(libraryProvider.notifier).setSortBy(sort);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'title', child: Text('Title')),
              const PopupMenuItem(value: 'artist', child: Text('Artist')),
              const PopupMenuItem(value: 'album', child: Text('Album')),
              const PopupMenuItem(value: 'recently_added', child: Text('Recently Added')),
            ],
          ),
          IconButton(
            icon: libraryState.isScanning
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.secondaryAccent),
                  )
                : const Icon(Icons.sync_rounded),
            tooltip: 'Scan Device Storage',
            onPressed: () {
              ref.read(libraryProvider.notifier).scanLibrary();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppColors.secondaryAccent,
          labelColor: AppColors.secondaryAccent,
          unselectedLabelColor: AppColors.subtleText,
          tabs: [
            Tab(text: 'All Songs (${libraryState.songs.length})'),
            Tab(text: 'Liked (${libraryState.likedSongs.length})'),
            Tab(text: 'Playlists (${libraryState.playlists.length})'),
            Tab(text: 'Albums (${libraryState.albums.length})'),
            Tab(text: 'Artists (${libraryState.artists.length})'),
            Tab(text: 'Genres (${libraryState.genres.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAllSongsList(libraryState.songs),
          _buildAllSongsList(libraryState.likedSongs, isLikedTab: true),
          _buildPlaylistsTab(libraryState),
          _buildAlbumsTab(libraryState),
          _buildArtistsTab(libraryState),
          _buildGenresTab(libraryState),
        ],
      ),
    );
  }

  Widget _buildAllSongsList(List<Song> songs, {bool isLikedTab = false}) {
    if (songs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isLikedTab ? Icons.favorite_border_rounded : Icons.music_note_rounded,
              size: 60,
              color: AppColors.subtleText,
            ),
            const SizedBox(height: 14),
            Text(isLikedTab ? 'No Liked Songs Yet' : 'No Songs Found', style: AppTypography.songTitleMedium),
            const SizedBox(height: 6),
            Text(
              isLikedTab ? 'Tap the heart icon on any song to add it here.' : 'Rescan device to import audio files.',
              style: AppTypography.bodyMedium,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      itemCount: songs.length,
      itemBuilder: (context, index) {
        final song = songs[index];
        final isPlaying = ref.watch(playerProvider).currentSong?.id == song.id &&
            ref.watch(playerProvider).isPlaying;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: AppColors.elevatedSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: AppColors.secondaryBackground,
                image: song.artworkUri != null && song.artworkUri!.startsWith('http')
                    ? DecorationImage(image: NetworkImage(song.artworkUri!), fit: BoxFit.cover)
                    : null,
              ),
              child: song.artworkUri == null || !song.artworkUri!.startsWith('http')
                  ? const Icon(Icons.music_note_rounded, color: AppColors.primaryAccent)
                  : null,
            ),
            title: Text(
              song.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.songTitleMedium,
            ),
            subtitle: Text(
              '${song.artist} • ${TimeFormatter.formatMs(song.durationMs)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.artistNameMedium,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    song.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: song.isFavorite ? AppColors.highlightAccent : AppColors.subtleText,
                    size: 20,
                  ),
                  onPressed: () {
                    ref.read(libraryProvider.notifier).toggleFavorite(song.id);
                  },
                ),
                CustomIconButton(
                  icon: isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  iconSize: 22,
                  size: 38,
                  color: AppColors.primaryAccent.withOpacity(0.2),
                  iconColor: AppColors.primaryAccent,
                  onTap: () {
                    if (isPlaying) {
                      ref.read(playerProvider.notifier).togglePlayPause();
                    } else {
                      ref.read(playerProvider.notifier).playSong(song, songs);
                    }
                  },
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded, color: AppColors.subtleText, size: 20),
                  onSelected: (action) {
                    if (action == 'add_next') {
                      ref.read(playerProvider.notifier).addNext(song);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Song added to play next')),
                      );
                    } else if (action == 'add_end') {
                      ref.read(playerProvider.notifier).addToEnd(song);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Song added to queue end')),
                      );
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'add_next', child: Text('Play Next')),
                    const PopupMenuItem(value: 'add_end', child: Text('Add to Queue End')),
                  ],
                ),
              ],
            ),
            onTap: () {
              ref.read(playerProvider.notifier).playSong(song, songs);
            },
          ),
        );
      },
    );
  }

  Widget _buildPlaylistsTab(LibraryState state) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryAccent,
        onPressed: () => _showCreatePlaylistDialog(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: state.playlists.isEmpty
          ? const Center(child: Text('No playlists created yet.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.playlists.length,
              itemBuilder: (context, index) {
                final pl = state.playlists[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: AppColors.elevatedSurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.playlist_play_rounded, color: AppColors.secondaryAccent, size: 36),
                    title: Text(pl.name, style: AppTypography.songTitleMedium),
                    subtitle: Text('${pl.songCount} tracks', style: AppTypography.artistNameMedium),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: AppColors.subtleText),
                      onPressed: () {
                        ref.read(libraryProvider.notifier).deletePlaylist(pl.id);
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildAlbumsTab(LibraryState state) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.85,
      ),
      itemCount: state.albums.length,
      itemBuilder: (context, index) {
        final album = state.albums[index];
        return Container(
          decoration: BoxDecoration(
            color: AppColors.elevatedSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.secondaryBackground,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: const Center(
                    child: Icon(Icons.album_rounded, size: 54, color: AppColors.primaryAccent),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      album['album'] ?? 'Unknown Album',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.songTitleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${album['song_count']} tracks',
                      style: AppTypography.metadata,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildArtistsTab(LibraryState state) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.artists.length,
      itemBuilder: (context, index) {
        final artist = state.artists[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: AppColors.elevatedSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: AppColors.secondaryBackground,
              child: Icon(Icons.person_rounded, color: AppColors.secondaryAccent),
            ),
            title: Text(artist, style: AppTypography.songTitleMedium),
            trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.subtleText),
          ),
        );
      },
    );
  }

  Widget _buildGenresTab(LibraryState state) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.genres.length,
      itemBuilder: (context, index) {
        final genre = state.genres[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: AppColors.elevatedSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: ListTile(
            leading: const Icon(Icons.category_rounded, color: AppColors.highlightAccent),
            title: Text(genre['genre'] ?? 'Unknown', style: AppTypography.songTitleMedium),
            subtitle: Text('${genre['song_count']} tracks', style: AppTypography.artistNameMedium),
          ),
        );
      },
    );
  }

  void _showCreatePlaylistDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create New Playlist'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Playlist Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.secondaryText)),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                ref.read(libraryProvider.notifier).createPlaylist(controller.text.trim());
                Navigator.pop(ctx);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
