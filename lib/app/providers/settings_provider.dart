import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/permissions/permission_service.dart';
import '../../data/repositories/settings_repository.dart';

class SettingsState {
  final bool reducedMotion;
  final bool autoResume;
  final String defaultMode;
  final bool permissionGranted;
  final double bassLevel;     // -10.0 to +10.0 dB
  final double midLevel;      // -10.0 to +10.0 dB
  final double trebleLevel;   // -10.0 to +10.0 dB
  final String activePreset;  // 'Flat', 'Bass Boost', 'Vocal', 'Acoustic', 'Electronic'

  const SettingsState({
    this.reducedMotion = false,
    this.autoResume = true,
    this.defaultMode = 'chill',
    this.permissionGranted = true,
    this.bassLevel = 0.0,
    this.midLevel = 0.0,
    this.trebleLevel = 0.0,
    this.activePreset = 'Flat',
  });

  SettingsState copyWith({
    bool? reducedMotion,
    bool? autoResume,
    String? defaultMode,
    bool? permissionGranted,
    double? bassLevel,
    double? midLevel,
    double? trebleLevel,
    String? activePreset,
  }) {
    return SettingsState(
      reducedMotion: reducedMotion ?? this.reducedMotion,
      autoResume: autoResume ?? this.autoResume,
      defaultMode: defaultMode ?? this.defaultMode,
      permissionGranted: permissionGranted ?? this.permissionGranted,
      bassLevel: bassLevel ?? this.bassLevel,
      midLevel: midLevel ?? this.midLevel,
      trebleLevel: trebleLevel ?? this.trebleLevel,
      activePreset: activePreset ?? this.activePreset,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final SettingsRepository _repo = SettingsRepository();

  SettingsNotifier() : super(const SettingsState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final motion = await _repo.getSetting(AppConstants.keyReducedMotion);
    final resume = await _repo.getSetting(AppConstants.keyAutoResume);
    final mode = await _repo.getSetting(AppConstants.keyDefaultMode);
    final hasPerm = await PermissionService.instance.hasAudioPermission();

    state = state.copyWith(
      reducedMotion: motion == 'true',
      autoResume: resume != 'false',
      defaultMode: mode ?? 'chill',
      permissionGranted: hasPerm,
    );
  }

  Future<void> toggleReducedMotion(bool value) async {
    state = state.copyWith(reducedMotion: value);
    await _repo.setSetting(AppConstants.keyReducedMotion, value.toString());
  }

  Future<void> toggleAutoResume(bool value) async {
    state = state.copyWith(autoResume: value);
    await _repo.setSetting(AppConstants.keyAutoResume, value.toString());
  }

  Future<void> setDefaultMode(String mode) async {
    state = state.copyWith(defaultMode: mode);
    await _repo.setSetting(AppConstants.keyDefaultMode, mode);
  }

  void setEqLevels({double? bass, double? mid, double? treble, String? preset}) {
    state = state.copyWith(
      bassLevel: bass ?? state.bassLevel,
      midLevel: mid ?? state.midLevel,
      trebleLevel: treble ?? state.trebleLevel,
      activePreset: preset ?? 'Custom',
    );
  }

  void applyPreset(String preset) {
    switch (preset) {
      case 'Bass Boost':
        setEqLevels(bass: 6.0, mid: 1.0, treble: -2.0, preset: 'Bass Boost');
        break;
      case 'Vocal':
        setEqLevels(bass: -2.0, mid: 5.0, treble: 2.0, preset: 'Vocal');
        break;
      case 'Acoustic':
        setEqLevels(bass: 2.0, mid: 3.0, treble: 4.0, preset: 'Acoustic');
        break;
      case 'Electronic':
        setEqLevels(bass: 5.0, mid: -1.0, treble: 5.0, preset: 'Electronic');
        break;
      case 'Flat':
      default:
        setEqLevels(bass: 0.0, mid: 0.0, treble: 0.0, preset: 'Flat');
        break;
    }
  }

  Future<void> checkPermissions() async {
    final hasPerm = await PermissionService.instance.hasAudioPermission();
    state = state.copyWith(permissionGranted: hasPerm);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});
