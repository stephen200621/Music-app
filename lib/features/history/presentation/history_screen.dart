import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/providers/history_provider.dart';
import '../../../app/providers/library_provider.dart';
import '../../../app/providers/player_provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/utils/time_formatter.dart';
import '../../../data/models/play_history_item.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final historyState = ref.watch(historyProvider);
    final allSongs = ref.watch(libraryProvider).songs;

    final filtered = historyState.history.where((item) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return (item.songTitle ?? '').toLowerCase().contains(q) ||
          (item.songArtist ?? '').toLowerCase().contains(q);
    }).toList();

    // Group items by 'Today', 'Yesterday', 'Earlier'
    final Map<String, List<PlayHistoryItem>> grouped = {};
    for (final item in filtered) {
      final header = TimeFormatter.getDateGrouping(item.startedAt);
      grouped.putIfAbsent(header, () => []).add(item);
    }

    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      appBar: AppBar(
        title: Text('Listening History', style: AppTypography.screenTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded),
            tooltip: 'Clear History',
            onPressed: historyState.history.isEmpty
                ? null
                : () => _confirmClearHistory(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search in History
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.elevatedSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: AppColors.mainText),
                decoration: const InputDecoration(
                  hintText: 'Search history...',
                  hintStyle: TextStyle(color: AppColors.subtleText),
                  prefixIcon: Icon(Icons.search, color: AppColors.secondaryText),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                onChanged: (val) {
                  setState(() => _searchQuery = val.trim());
                },
              ),
            ),
          ),

          // Timeline List
          Expanded(
            child: historyState.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.secondaryAccent))
                : filtered.isEmpty
                    ? _buildEmptyHistory()
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: grouped.keys.length,
                        itemBuilder: (context, groupIndex) {
                          final groupKey = grouped.keys.elementAt(groupIndex);
                          final items = grouped[groupKey]!;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                                child: Text(
                                  groupKey.toUpperCase(),
                                  style: AppTypography.badgeText.copyWith(
                                    color: AppColors.secondaryAccent,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                              ...items.map((item) => _buildHistoryTile(context, item, allSongs)),
                            ],
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTile(
    BuildContext context,
    PlayHistoryItem item,
    List allSongs,
  ) {
    final song = allSongs.firstWhere(
      (s) => s.id == item.songId,
      orElse: () => null,
    );

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
            image: item.artworkUri != null && item.artworkUri!.startsWith('http')
                ? DecorationImage(image: NetworkImage(item.artworkUri!), fit: BoxFit.cover)
                : null,
          ),
          child: item.artworkUri == null || !item.artworkUri!.startsWith('http')
              ? const Icon(Icons.music_note, color: AppColors.primaryAccent)
              : null,
        ),
        title: Text(
          item.songTitle ?? 'Untitled Track',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.songTitleMedium,
        ),
        subtitle: Row(
          children: [
            Text(
              item.songArtist ?? 'Unknown Artist',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.artistNameMedium,
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: item.eventType == HistoryEventType.skipped
                    ? AppColors.error.withOpacity(0.2)
                    : AppColors.success.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                item.eventType == HistoryEventType.skipped
                    ? 'SKIPPED'
                    : '${item.completionPercentage}%',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: item.eventType == HistoryEventType.skipped
                      ? AppColors.error
                      : AppColors.success,
                ),
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.replay_rounded, color: AppColors.secondaryAccent),
              tooltip: 'Replay Track',
              onPressed: () {
                if (song != null) {
                  ref.read(playerProvider.notifier).playSong(song, ref.read(libraryProvider).songs);
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.subtleText, size: 20),
              tooltip: 'Delete Entry',
              onPressed: () {
                ref.read(historyProvider.notifier).removeItem(item.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyHistory() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.history_toggle_off_rounded, size: 64, color: AppColors.subtleText),
          const SizedBox(height: 16),
          Text('No History Recorded', style: AppTypography.screenTitle),
          const SizedBox(height: 8),
          Text(
            'Songs you listen to will automatically appear here.',
            style: AppTypography.bodyMedium,
          ),
        ],
      ),
    );
  }

  void _confirmClearHistory(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Listening History?'),
        content: const Text('This will delete all past playback timelines from your device.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.secondaryText)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(historyProvider.notifier).clearAllHistory();
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}
