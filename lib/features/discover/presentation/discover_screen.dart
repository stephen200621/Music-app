import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../animations/perspective_card.dart';
import '../../../app/providers/library_provider.dart';
import '../../../app/providers/mode_provider.dart';
import '../../../app/providers/player_provider.dart';
import '../../../app/providers/recommendation_provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../data/models/recommendation_item.dart';

class DiscoverScreen extends ConsumerWidget {
  const DiscoverScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recState = ref.watch(recommendationProvider);
    final activeMode = ref.watch(modeProvider);
    final allSongs = ref.watch(libraryProvider).songs;

    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      appBar: AppBar(
        title: Text('Discover AI', style: AppTypography.screenTitle),
        actions: [
          IconButton(
            icon: recState.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.secondaryAccent),
                  )
                : const Icon(Icons.auto_awesome_rounded, color: AppColors.secondaryAccent),
            tooltip: 'Recalculate AI Recommendations',
            onPressed: () {
              ref.read(recommendationProvider.notifier).recalculateRecommendations();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mode Banner
            PerspectiveCard(
              gradient: LinearGradient(
                colors: [
                  activeMode.primaryColor.withOpacity(0.35),
                  activeMode.secondaryColor.withOpacity(0.15),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: activeMode.primaryColor.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(activeMode.icon, color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('AI Active Bias: ${activeMode.title}', style: AppTypography.controlLabel),
                        const SizedBox(height: 2),
                        Text(
                          'Prioritizing ${(activeMode.targetEnergy * 100).toInt()}% energy level and mood affinity.',
                          style: AppTypography.metadata,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Privacy Notice Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.elevatedSurface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shield_outlined, size: 16, color: AppColors.success),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '100% On-Device AI. Listening habits never leave your phone.',
                      style: AppTypography.metadata.copyWith(color: AppColors.secondaryText),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            if (recState.items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(Icons.bubble_chart_rounded, size: 60, color: AppColors.subtleText),
                      const SizedBox(height: 16),
                      Text('Recommendations Initializing', style: AppTypography.songTitleMedium),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          'Your listening history will feed the neural heuristic weights. As you play, like, or skip tracks, VYBE 3D personalizes this feed.',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recState.items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = recState.items[index];
                  return _buildRecommendationCard(context, ref, item, allSongs);
                },
              ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationCard(
    BuildContext context,
    WidgetRef ref,
    RecommendationItem item,
    List dynamicQueue,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.elevatedSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Category Chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryAccent.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.category.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondaryAccent,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const Spacer(),
                // Match Score
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${item.score.toInt()}% MATCH',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                // Artwork
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppColors.secondaryBackground,
                    image: item.song.artworkUri != null && item.song.artworkUri!.startsWith('http')
                        ? DecorationImage(
                            image: NetworkImage(item.song.artworkUri!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: item.song.artworkUri == null || !item.song.artworkUri!.startsWith('http')
                      ? const Icon(Icons.music_note_rounded, color: AppColors.primaryAccent)
                      : null,
                ),
                const SizedBox(width: 14),
                // Title and Artist
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.song.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.songTitleMedium,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${item.song.artist} • ${item.song.genre}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.artistNameMedium,
                      ),
                    ],
                  ),
                ),
                // Play Action
                IconButton(
                  icon: const Icon(
                    Icons.play_circle_fill_rounded,
                    size: 38,
                    color: AppColors.primaryAccent,
                  ),
                  onPressed: () {
                    ref.read(playerProvider.notifier).playSong(
                          item.song,
                          ref.read(libraryProvider).songs,
                        );
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(color: AppColors.divider),
            const SizedBox(height: 6),
            // Algorithmic Rationale Pill
            Row(
              children: [
                const Icon(Icons.insights_rounded, size: 14, color: AppColors.secondaryAccent),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    item.reason,
                    style: AppTypography.metadata.copyWith(
                      color: AppColors.secondaryText,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                // Dismiss recommendation button
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 16, color: AppColors.subtleText),
                  tooltip: 'Dismiss recommendation',
                  onPressed: () {
                    ref.read(recommendationProvider.notifier).dismissRecommendation(item.song.id);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
