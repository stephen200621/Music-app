import 'dart:async';
import '../audio/audio_player_service.dart';

class SleepTimerService {
  static final SleepTimerService instance = SleepTimerService._();
  SleepTimerService._();

  Timer? _ticker;
  int _remainingSeconds = 0;
  final StreamController<int> _remainingController = StreamController<int>.broadcast();

  Stream<int> get remainingSecondsStream => _remainingController.stream;
  int get remainingSeconds => _remainingSeconds;
  bool get isActive => _remainingSeconds > 0;

  void startTimer(int minutes) {
    cancelTimer();
    _remainingSeconds = minutes * 60;
    _remainingController.add(_remainingSeconds);

    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) async {
      _remainingSeconds--;
      _remainingController.add(_remainingSeconds);

      // Smooth volume fade out in last 60 seconds
      if (_remainingSeconds <= 60 && _remainingSeconds > 0) {
        final volume = (_remainingSeconds / 60.0).clamp(0.05, 1.0);
        AudioPlayerService.instance.handler.player.setVolume(volume);
      }

      if (_remainingSeconds <= 0) {
        cancelTimer();
        // Pause playback
        await AudioPlayerService.instance.pause();
        // Restore volume for next session
        await AudioPlayerService.instance.handler.player.setVolume(1.0);
      }
    });
  }

  void cancelTimer() {
    _ticker?.cancel();
    _ticker = null;
    _remainingSeconds = 0;
    _remainingController.add(0);
    // Reset volume to 1.0
    try {
      AudioPlayerService.instance.handler.player.setVolume(1.0);
    } catch (_) {}
  }
}
