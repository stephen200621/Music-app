import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../animations/music_orb.dart';
import '../../../animations/perspective_card.dart';
import '../../../app/providers/library_provider.dart';
import '../../../app/providers/mode_provider.dart';
import '../../../app/providers/player_provider.dart';
import '../../../app/providers/recommendation_provider.dart';
import '../../../app/providers/settings_provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../data/models/music_mode.dart';
import '../../../data/models/song.dart';
import '../../../shared_widgets/custom_icon_button.dart';
import '../../../shared_widgets/mini_player.dart';
import '../../discover/presentation/discover_screen.dart';
import '../../history/presentation/history_screen.dart';
import '../../library/presentation/library_screen.dart';
import '../../music_modes/presentation/music_modes_screen.dart';
import '../../player/presentation/now_playing_screen.dart';
import '../../settings/presentation/settings_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedNavIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If user clicked bottom nav tabs, display the corresponding view
    Widget bodyContent;
    switch (_selectedNavIndex) {
      case 1:
        bodyContent = const DiscoverScreen();
        break;
      case 2:
        bodyContent = const LibraryScreen();
        break;
      case 3:
        bodyContent = const HistoryScreen();
        break;
      case 0:
      default:
        bodyContent = _buildHomeDashboard();
        break;
    }

    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: bodyContent),
            const MiniPlayer(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedNavIndex,
        onTap: (index) {
          setState(() => _selectedNavIndex = index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome_rounded),
            label: 'Discover',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_music_rounded),
            label: 'Library',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_rounded),
            label: 'History',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeDashboard() {
    final playerState = ref.watch(playerProvider);
    final activeMode = ref.watch(modeProvider);
    final libraryState = ref.watch(libraryProvider);
    final recState = ref.watch(recommendationProvider);
    final settingsState = ref.watch(settingsProvider);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1 & 2: Header Greeting & Profile/Settings Control
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getGreeting(),
                      style: AppTypography.artistNameMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'VYBE 3D',
                      style: AppTypography.displayMedium.copyWith(
                        foreground: Paint()
                          ..shader = AppColors.cyanPurpleGradient.createShader(
                            const Rect.fromLTWH(0, 0, 180, 40),
                          ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    CustomIconButton(
                      icon: Icons.equalizer_rounded,
                      iconColor: AppColors.secondaryAccent,
                      tooltip: 'Music Modes',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const MusicModesScreen()),
                        );
                      },
                    ),
                    CustomIconButton(
                      icon: Icons.settings_outlined,
                      tooltip: 'Settings',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SettingsScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 18),

            // 4: Search field
            Container(
              decoration: BoxDecoration(
                color: AppColors.elevatedSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: AppColors.mainText),
                decoration: InputDecoration(
                  hintText: 'Search songs, artists, albums...',
                  hintStyle: const TextStyle(color: AppColors.subtleText),
                  prefixIcon: const Icon(Icons.search, color: AppColors.secondaryText),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: AppColors.subtleText),
                          onPressed: () {
                            _searchController.clear();
                            ref.read(libraryProvider.notifier).setSearchQuery('');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                onChanged: (val) {
                  ref.read(libraryProvider.notifier).setSearchQuery(val);
                },
              ),
            ),

            const SizedBox(height: 24),

            // 3: Prominent Animated 3D Music Orb
            Center(
              child: Column(
                children: [
                  MusicOrb(
                    size: 210,
                    isPlaying: playerState.isPlaying,
                    reducedMotion: settingsState.reducedMotion,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const NowPlayingScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  Text(
                    playerState.isPlaying ? 'Now Vibing' : 'Tap Orb to Open Player',
                    style: AppTypography.metadata.copyWith(
                      color: AppColors.secondaryAccent,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 5: Continue Listening Section
            if (playerState.currentSong != null) ...[
              Text('Continue Listening', style: AppTypography.sectionHeading),
              const SizedBox(height: 12),
              PerspectiveCard(
                onTap: () {
                  ref.read(playerProvider.notifier).playSong(
                        playerState.currentSong!,
                        libraryState.songs,
                      );
                },
                gradient: LinearGradient(
                  colors: [
                    AppColors.elevatedSurface,
                    activeMode.primaryColor.withOpacity(0.18),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: AppColors.secondaryBackground,
                        image: playerState.currentSong?.artworkUri != null &&
                                playerState.currentSong!.artworkUri!.startsWith('http')
                            ? DecorationImage(
                                image: NetworkImage(playerState.currentSong!.artworkUri!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: playerState.currentSong?.artworkUri == null ||
                              !playerState.currentSong!.artworkUri!.startsWith('http')
                          ? const Icon(Icons.play_circle_fill, color: AppColors.primaryAccent, size: 30)
                          : null,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            playerState.currentSong!.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.songTitleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${playerState.currentSong!.artist} • Mode: ${activeMode.title}',
                            style: AppTypography.artistNameMedium,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.primaryGradient,
                        boxShadow: AppColors.primaryGlow,
                      ),
                      child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 22),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // 8 & 9: Quick-Access Music Modes / Choose Your Mood
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Choose Your Mood', style: AppTypography.sectionHeading),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MusicModesScreen()),
                    );
                  },
                  child: const Text('View All', style: TextStyle(color: AppColors.secondaryAccent)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: MusicMode.allModes.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final mode = MusicMode.allModes[index];
                  final isCurrent = mode.type == activeMode.type;

                  return PerspectiveCard(
                    onTap: () {
                      ref.read(modeProvider.notifier).selectMode(mode);
                    },
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    backgroundColor: isCurrent ? mode.primaryColor.withOpacity(0.24) : AppColors.elevatedSurface,
                    border: isCurrent
                        ? Border.all(color: mode.primaryColor, width: 1.5)
                        : Border.all(color: AppColors.glassBorder),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(mode.icon, color: mode.primaryColor, size: 28),
                        const SizedBox(height: 8),
                        Text(
                          mode.title,
                          style: AppTypography.controlLabel.copyWith(
                            color: isCurrent ? Colors.white : AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 26),

            // 7: "Made For You" AI Recommendations Shelf
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Made For You', style: AppTypography.sectionHeading),
                IconButton(
                  icon: const Icon(Icons.refresh_rounded, color: AppColors.secondaryAccent),
                  onPressed: () {
                    ref.read(recommendationProvider.notifier).recalculateRecommendations();
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (recState.items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    'Listening data is building. Play songs to receive tailored AI recommendations.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMedium,
                  ),
                ),
              )
            else
              SizedBox(
                height: 190,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: recState.items.take(8).length,
                  separatorBuilder: (_, __) => const SizedBox(width: 14),
                  itemBuilder: (context, index) {
                    final item = recState.items[index];
                    return _buildSongCard(item.song, item.category);
                  },
                ),
              ),

            const SizedBox(height: 26),

            // 6: "Recently Added & Library Shelf"
            Text('From Your Library', style: AppTypography.sectionHeading),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: libraryState.songs.take(6).length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final song = libraryState.songs[index];
                return _buildListTileSong(song, libraryState.songs);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSongCard(Song song, String badgeLabel) {
    return GestureDetector(
      onTap: () {
        final allSongs = ref.read(libraryProvider).songs;
        ref.read(playerProvider.notifier).playSong(song, allSongs);
      },
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          color: AppColors.elevatedSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Container(
                    height: 110,
                    width: 140,
                    color: AppColors.secondaryBackground,
                    child: song.artworkUri != null && song.artworkUri!.startsWith('http')
                        ? Image.network(song.artworkUri!, fit: BoxFit.cover)
                        : Center(
                            child: Icon(
                              Icons.album_rounded,
                              size: 40,
                              color: AppColors.primaryAccent.withOpacity(0.6),
                            ),
                          ),
                  ),
                ),
                Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      badgeLabel,
                      style: const TextStyle(fontSize: 9, color: AppColors.secondaryAccent, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.mainText),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    song.artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: AppColors.secondaryText),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTileSong(Song song, List<Song> queue) {
    final isCurrent = ref.watch(playerProvider).currentSong?.id == song.id;

    return Container(
      decoration: BoxDecoration(
        color: isCurrent ? AppColors.primaryAccent.withOpacity(0.12) : AppColors.elevatedSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCurrent ? AppColors.primaryAccent.withOpacity(0.5) : AppColors.glassBorder,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
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
          style: AppTypography.songTitleMedium.copyWith(
            color: isCurrent ? AppColors.secondaryAccent : AppColors.mainText,
          ),
        ),
        subtitle: Text(
          '${song.artist} • ${song.genre}',
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
            IconButton(
              icon: Icon(
                isCurrent && ref.watch(playerProvider).isPlaying
                    ? Icons.pause_circle_filled_rounded
                    : Icons.play_circle_filled_rounded,
                color: AppColors.primaryAccent,
                size: 32,
              ),
              onPressed: () {
                if (isCurrent) {
                  ref.read(playerProvider.notifier).togglePlayPause();
                } else {
                  ref.read(playerProvider.notifier).playSong(song, queue);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
