import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/music_mode.dart';
import '../../data/repositories/settings_repository.dart';
import '../../services/audio/audio_player_service.dart';

class ModeNotifier extends StateNotifier<MusicMode> {
  final SettingsRepository _settingsRepo = SettingsRepository();

  ModeNotifier() : super(MusicMode.getMode(ModeType.chill)) {
    _loadSavedMode();
  }

  Future<void> _loadSavedMode() async {
    final savedKey = await _settingsRepo.getSetting('setting_active_mode');
    if (savedKey != null) {
      final mode = MusicMode.getMode(ModeType.fromString(savedKey));
      state = mode;
      AudioPlayerService.instance.setMode(mode.title.toLowerCase());
    }
  }

  Future<void> selectMode(MusicMode mode) async {
    state = mode;
    AudioPlayerService.instance.setMode(mode.title.toLowerCase());
    await _settingsRepo.setSetting('setting_active_mode', mode.type.name);
  }
}

final modeProvider = StateNotifierProvider<ModeNotifier, MusicMode>((ref) {
  return ModeNotifier();
});
