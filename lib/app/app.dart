import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/player_provider.dart';
import 'theme/app_theme.dart';
import '../features/home/presentation/home_screen.dart';

class VybeApp extends ConsumerStatefulWidget {
  const VybeApp({Key? key}) : super(key: key);

  @override
  ConsumerState<VybeApp> createState() => _VybeAppState();
}

class _VybeAppState extends ConsumerState<VybeApp> {
  @override
  void initState() {
    super.initState();
    // Auto-restore previous playback session & queue on launch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(playerProvider.notifier).restorePreviousSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VYBE 3D',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const HomeScreen(),
    );
  }
}
