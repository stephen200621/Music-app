import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/recommendation_item.dart';
import '../../services/recommendations/ai_recommendation_engine.dart';
import 'mode_provider.dart';
import 'player_provider.dart';

class RecommendationState {
  final List<RecommendationItem> items;
  final bool isLoading;
  final String? errorMessage;

  const RecommendationState({
    this.items = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  RecommendationState copyWith({
    List<RecommendationItem>? items,
    bool? isLoading,
    String? errorMessage,
  }) {
    return RecommendationState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class RecommendationNotifier extends StateNotifier<RecommendationState> {
  final Ref _ref;
  final AiRecommendationEngine _engine;

  RecommendationNotifier(this._ref, {AiRecommendationEngine? engine})
      : _engine = engine ?? AiRecommendationEngine(),
        super(const RecommendationState()) {
    recalculateRecommendations();
  }

  Future<void> recalculateRecommendations() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final currentMode = _ref.read(modeProvider);
      final currentSongId = _ref.read(playerProvider).currentSong?.id;

      final results = await _engine.generateRecommendations(
        currentMode: currentMode,
        currentPlayingSongId: currentSongId,
        limit: 25,
      );

      state = state.copyWith(items: results, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Recommendations will populate as you play more music.',
      );
    }
  }

  void dismissRecommendation(String songId) {
    final updated = state.items.where((item) => item.song.id != songId).toList();
    state = state.copyWith(items: updated);
  }
}

final recommendationProvider =
    StateNotifierProvider<RecommendationNotifier, RecommendationState>((ref) {
  // Watch mode changes to automatically trigger re-ranking
  ref.watch(modeProvider);
  return RecommendationNotifier(ref);
});
