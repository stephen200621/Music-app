import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/play_history_item.dart';
import '../../data/repositories/history_repository.dart';

class HistoryState {
  final List<PlayHistoryItem> history;
  final bool isLoading;

  const HistoryState({
    this.history = const [],
    this.isLoading = false,
  });

  HistoryState copyWith({
    List<PlayHistoryItem>? history,
    bool? isLoading,
  }) {
    return HistoryState(
      history: history ?? this.history,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class HistoryNotifier extends StateNotifier<HistoryState> {
  final HistoryRepository _repo;

  HistoryNotifier({HistoryRepository? repo})
      : _repo = repo ?? HistoryRepository(),
        super(const HistoryState()) {
    loadHistory();
  }

  Future<void> loadHistory() async {
    state = state.copyWith(isLoading: true);
    final list = await _repo.getHistory(limit: 200);
    state = state.copyWith(history: list, isLoading: false);
  }

  Future<void> removeItem(int id) async {
    await _repo.removeHistoryItem(id);
    await loadHistory();
  }

  Future<void> clearAllHistory() async {
    await _repo.clearAllHistory();
    state = state.copyWith(history: []);
  }

  Future<String> exportHistoryJson() async {
    return await _repo.exportHistoryJson();
  }
}

final historyProvider = StateNotifierProvider<HistoryNotifier, HistoryState>((ref) {
  return HistoryNotifier();
});
