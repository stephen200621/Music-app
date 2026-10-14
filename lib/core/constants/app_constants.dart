class AppConstants {
  AppConstants._();

  static const String appName = 'VYBE 3D';
  static const String appVersion = '1.0.0';
  static const String dbName = 'vybe3d_player.db';
  static const int dbVersion = 1;

  // History Recording Thresholds
  static const int minPlaybackMsForHistory = 15000; // 15 seconds to count as play
  static const int minCompletionPercentage = 80;    // 80% counts as completed
  static const int skipThresholdMs = 20000;          // skipped before 20s = skip event

  // Recency penalty
  static const Duration recencyPenaltyWindow = Duration(hours: 3);

  // Default Settings Keys
  static const String keyReducedMotion = 'setting_reduced_motion';
  static const String keyDefaultMode = 'setting_default_mode';
  static const String keyAutoResume = 'setting_auto_resume';
  static const String keyCrossfadeEnabled = 'setting_crossfade';
  static const String keyGaplessEnabled = 'setting_gapless';
}
