import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../animations/audio_visualizer.dart';
import '../../../animations/floating_album_art.dart';
import '../../../animations/vinyl_disc.dart';
import '../../../app/providers/mode_provider.dart';
import '../../../app/providers/player_provider.dart';
import '../../../app/providers/settings_provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/utils/time_formatter.dart';
import '../../../data/models/music_mode.dart';
import '../../../shared_widgets/custom_icon_button.dart';
import '../../equalizer/presentation/equalizer_screen.dart';
import '../../music_modes/presentation/music_modes_screen.dart';
import '../../queue/presentation/queue_screen.dart';

class NowPlayingScreen extends ConsumerStatefulWidget {
  const NowPlayingScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends ConsumerState<NowPlayingScreen> {
  bool _showVinyl = true;
  double? _draggedSeekValue;

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(playerProvider);
    final currentSong = playerState.currentSong;
    final activeMode = ref.watch(modeProvider);
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 32),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Column(
          children: [
            Text(
              'PLAYING FROM MODE',
              style: AppTypography.metadata.copyWith(letterSpacing: 1.4),
            ),
            const SizedBox(height: 2),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MusicModesScreen()),
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(activeMode.icon, size: 14, color: activeMode.primaryColor),
                  const SizedBox(width: 4),
                  Text(
                    activeMode.title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: activeMode.primaryColor,
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down, size: 18, color: AppColors.secondaryText),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showVinyl ? Icons.album_rounded : Icons.crop_square_rounded,
              color: _showVinyl ? AppColors.secondaryAccent : AppColors.subtleText,
            ),
            tooltip: 'Toggle Vinyl Disc',
            onPressed: () {
              setState(() => _showVinyl = !_showVinyl);
            },
          ),
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            tooltip: 'Audio & Equalizer Settings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EqualizerScreen()),
              );
            },
          ),
        ],
      ),
      body: currentSong == null
          ? _buildEmptyState()
          : SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),

                      // Floating 3D Album Artwork + Optional Rotating Vinyl Disc
                      SizedBox(
                        height: 300,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Vinyl disc positioned behind cover
                            if (_showVinyl)
                              Positioned(
                                right: 10,
                                child: VinylDisc(
                                  size: 240,
                                  isPlaying: playerState.isPlaying,
                                  reducedMotion: settings.reducedMotion,
                                ),
                              ),

                            // Floating 3D Artwork
                            Positioned(
                              left: _showVinyl ? 16 : null,
                              child: FloatingAlbumArt(
                                song: currentSong,
                                size: 250,
                                isPlaying: playerState.isPlaying,
                                reducedMotion: settings.reducedMotion,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Audio Visualizer
                      AudioVisualizer(
                        isPlaying: playerState.isPlaying,
                        reducedMotion: settings.reducedMotion,
                        barCount: 32,
                        height: 32,
                      ),

                      const SizedBox(height: 20),

                      // Title, Artist, and Favorite Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  currentSong.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.songTitleLarge,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${currentSong.artist} • ${currentSong.album}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.artistNameLarge,
                                ),
                              ],
                            ),
                          ),
                          CustomIconButton(
                            icon: currentSong.isFavorite
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            iconColor: currentSong.isFavorite
                                ? AppColors.highlightAccent
                                : AppColors.secondaryText,
                            hasGlow: currentSong.isFavorite,
                            glowShadow: [
                              BoxShadow(
                                color: AppColors.highlightAccent.withOpacity(0.4),
                                blurRadius: 16,
                              )
                            ],
                            onTap: () {
                              ref.read(playerProvider.notifier).toggleFavoriteCurrent();
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Interactive Seek Bar
                      _buildSeekBar(playerState),

                      const SizedBox(height: 18),

                      // Transport Playback Controls
                      _buildTransportControls(playerState),

                      const SizedBox(height: 20),

                      // Bottom Action Row (Queue, Modes, Sleep Timer Indicator)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton.icon(
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.secondaryText,
                              backgroundColor: AppColors.elevatedSurface,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            icon: const Icon(Icons.speed_rounded, size: 18),
                            label: Text('${(currentSong.energy * 100).toInt()}% Energy'),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: const Icon(Icons.queue_music_rounded, color: AppColors.mainText, size: 28),
                            tooltip: 'Playback Queue',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const QueueScreen()),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildSeekBar(PlayerState playerState) {
    final totalMs = playerState.duration.inMilliseconds;
    final currentMs = _draggedSeekValue?.toInt() ?? playerState.position.inMilliseconds;
    final maxVal = totalMs > 0 ? totalMs.toDouble() : 1.0;
    final val = currentMs.toDouble().clamp(0.0, maxVal);

    return Column(
      children: [
        Slider(
          value: val,
          min: 0.0,
          max: maxVal,
          onChanged: (newVal) {
            setState(() {
              _draggedSeekValue = newVal;
            });
          },
          onChangeEnd: (newVal) {
            ref.read(playerProvider.notifier).seek(Duration(milliseconds: newVal.toInt()));
            setState(() {
              _draggedSeekValue = null;
            });
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                TimeFormatter.formatMs(currentMs),
                style: AppTypography.metadata,
              ),
              Text(
                TimeFormatter.formatMs(totalMs),
                style: AppTypography.metadata,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTransportControls(PlayerState playerState) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Shuffle Toggle
        CustomIconButton(
          icon: Icons.shuffle_rounded,
          iconColor: playerState.isShuffle ? AppColors.secondaryAccent : AppColors.subtleText,
          size: 42,
          iconSize: 22,
          onTap: () {
            ref.read(playerProvider.notifier).toggleShuffle();
          },
        ),

        // Previous
        CustomIconButton(
          icon: Icons.skip_previous_rounded,
          iconColor: AppColors.mainText,
          size: 54,
          iconSize: 36,
          onTap: () {
            ref.read(playerProvider.notifier).previous();
          },
        ),

        // Play / Pause Prominent Center Button
        GestureDetector(
          onTap: () {
            ref.read(playerProvider.notifier).togglePlayPause();
          },
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.primaryGradient,
              boxShadow: AppColors.primaryGlow,
            ),
            child: Center(
              child: playerState.isLoading
                  ? const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                    )
                  : Icon(
                      playerState.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      size: 40,
                      color: Colors.white,
                    ),
            ),
          ),
        ),

        // Next
        CustomIconButton(
          icon: Icons.skip_next_rounded,
          iconColor: AppColors.mainText,
          size: 54,
          iconSize: 36,
          onTap: () {
            ref.read(playerProvider.notifier).next();
          },
        ),

        // Repeat Cycle
        CustomIconButton(
          icon: playerState.repeatMode == 'one'
              ? Icons.repeat_one_rounded
              : Icons.repeat_rounded,
          iconColor: playerState.repeatMode != 'off'
              ? AppColors.secondaryAccent
              : AppColors.subtleText,
          size: 42,
          iconSize: 22,
          onTap: () {
            ref.read(playerProvider.notifier).cycleRepeatMode();
          },
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.music_off_rounded, size: 70, color: AppColors.subtleText),
          const SizedBox(height: 16),
          Text('No Track Selected', style: AppTypography.screenTitle),
          const SizedBox(height: 8),
          Text(
            'Select any song from Library or Discover to begin playing',
            style: AppTypography.bodyMedium,
          ),
        ],
      ),
    );
  }
}
