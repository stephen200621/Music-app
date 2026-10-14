import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/providers/library_provider.dart';
import '../../../app/providers/player_provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/utils/time_formatter.dart';
import '../../../data/models/song.dart';
import '../../../data/repositories/playlist_repository.dart';

class QueueScreen extends ConsumerWidget {
  const QueueScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerProvider);
    final queue = playerState.queue;
    final currentSong = playerState.currentSong;

    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      appBar: AppBar(
        title: Text('Playback Queue', style: AppTypography.screenTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.playlist_add_rounded),
            tooltip: 'Save Queue as Playlist',
            onPressed: queue.isEmpty
                ? null
                : () => _showSavePlaylistDialog(context, ref, queue),
          ),
          IconButton(
            icon: const Icon(Icons.clear_all_rounded),
            tooltip: 'Clear Queue',
            onPressed: queue.isEmpty
                ? null
                : () => _confirmClearQueue(context, ref),
          ),
        ],
      ),
      body: queue.isEmpty
          ? _buildEmptyQueue()
          : ReorderableListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: queue.length,
              onReorder: (oldIndex, newIndex) {
                ref.read(playerProvider.notifier).reorderQueue(oldIndex, newIndex);
              },
              itemBuilder: (context, index) {
                final song = queue[index];
                final isCurrent = currentSong?.id == song.id;

                return Container(
                  key: ValueKey('${song.id}_$index'),
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? AppColors.primaryAccent.withOpacity(0.18)
                        : AppColors.elevatedSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isCurrent
                          ? AppColors.primaryAccent
                          : AppColors.glassBorder,
                      width: isCurrent ? 1.5 : 1.0,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isCurrent)
                          const Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: Icon(
                              Icons.volume_up_rounded,
                              color: AppColors.secondaryAccent,
                              size: 20,
                            ),
                          ),
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
                              ? const Icon(Icons.music_note_rounded, color: AppColors.primaryAccent)
                              : null,
                        ),
                      ],
                    ),
                    title: Text(
                      song.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.songTitleMedium.copyWith(
                        color: isCurrent ? AppColors.secondaryAccent : AppColors.mainText,
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      '${song.artist} • ${TimeFormatter.formatMs(song.durationMs)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.artistNameMedium,
                    ),
                    onTap: () {
                      ref.read(playerProvider.notifier).playQueueIndex(index);
                    },
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.subtleText),
                          tooltip: 'Remove from queue',
                          onPressed: () {
                            ref.read(playerProvider.notifier).removeFromQueue(index);
                          },
                        ),
                        const Icon(Icons.drag_handle_rounded, color: AppColors.secondaryText),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildEmptyQueue() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.queue_music_rounded, size: 70, color: AppColors.subtleText),
          const SizedBox(height: 16),
          Text('Queue is Empty', style: AppTypography.screenTitle),
          const SizedBox(height: 8),
          Text(
            'Add tracks from your Library, History, or Discover tab.',
            style: AppTypography.bodyMedium,
          ),
        ],
      ),
    );
  }

  void _confirmClearQueue(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Queue?'),
        content: const Text('Are you sure you want to remove all songs from the playback queue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.secondaryText)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(playerProvider.notifier).clearQueue();
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showSavePlaylistDialog(BuildContext context, WidgetRef ref, List<Song> queue) {
    final controller = TextEditingController(text: 'Queue Playlist');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Save Queue as Playlist'),
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
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                final repo = PlaylistRepository();
                await repo.saveQueueAsPlaylist(controller.text.trim(), queue);
                ref.read(libraryProvider.notifier).refreshLibrary();
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Playlist "${controller.text.trim()}" saved!')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
