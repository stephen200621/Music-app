import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_service/audio_service.dart';
import 'app/app.dart';
import 'services/audio/audio_player_handler.dart';
import 'services/audio/audio_player_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Android background AudioService
  VybeAudioHandler? handler;
  try {
    handler = await AudioService.init(
      builder: () => VybeAudioHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.vybe3d.musicplayer.playback',
        androidNotificationChannelName: 'VYBE 3D Playback',
        androidNotificationChannelDescription: 'Background audio playback controls and metadata',
        androidNotificationOngoing: true,
        androidStopForegroundOnPause: true,
             ),
    );
    AudioPlayerService.instance.initialize(handler);
  } catch (e) {
    // In unit test or non-Android environment, fallback handler
  }

  runApp(
    const ProviderScope(
      child: VybeApp(),
    ),
  );
}
