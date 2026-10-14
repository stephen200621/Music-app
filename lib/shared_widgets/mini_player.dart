import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app/providers/player_provider.dart';
import '../app/theme/app_colors.dart';
import '../app/theme/app_typography.dart';
import '../features/player/presentation/now_playing_screen.dart';
import 'custom_icon_button.dart';

class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerProvider);
    final song = playerState.currentSong;

    if (song == null) {
      return const SizedBox.shrink();
    }

    final totalMs = playerState.duration.inMilliseconds;
    final currentMs = playerState.position.inMilliseconds;
    final progress = totalMs > 0 ? (currentMs / totalMs).clamp(0.0, 1.0) : 0.0;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const NowPlayingScreen(),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.elevatedSurface.withOpacity(0.95),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.glassBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: AppColors.primaryAccent.withOpacity(0.12),
              blurRadius: 20,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Progress Line
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white.withOpacity(0.06),
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondaryAccent),
                minHeight: 2.5,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    // Artwork Thumbnail
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: AppColors.secondaryBackground,
                        image: song.artworkUri != null && song.artworkUri!.startsWith('http')
                            ? DecorationImage(
                                image: NetworkImage(song.artworkUri!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: song.artworkUri == null || !song.artworkUri!.startsWith('http')
                          ? const Center(
                              child: Icon(
                                Icons.music_note_rounded,
                                color: AppColors.primaryAccent,
                                size: 24,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    // Title & Artist
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            song.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.songTitleMedium,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            song.artist,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.artistNameMedium,
                          ),
                        ],
                      ),
                    ),
                    // Play / Pause Button
                    CustomIconButton(
                      icon: playerState.isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      iconSize: 28,
                      size: 40,
                      hasGlow: playerState.isPlaying,
                      iconColor: AppColors.mainText,
                      onTap: () {
                        ref.read(playerProvider.notifier).togglePlayPause();
                      },
                    ),
                    // Next Track Button
                    CustomIconButton(
                      icon: Icons.skip_next_rounded,
                      iconSize: 26,
                      size: 40,
                      iconColor: AppColors.secondaryText,
                      onTap: () {
                        ref.read(playerProvider.notifier).next();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
