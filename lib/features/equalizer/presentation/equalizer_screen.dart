import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/providers/settings_provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../services/sleep_timer/sleep_timer_service.dart';

class EqualizerScreen extends ConsumerStatefulWidget {
  const EqualizerScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<EqualizerScreen> createState() => _EqualizerScreenState();
}

class _EqualizerScreenState extends ConsumerState<EqualizerScreen> {
  final List<String> _presets = ['Flat', 'Bass Boost', 'Vocal', 'Acoustic', 'Electronic'];

  @override
  Widget build(BuildContext context) {
    final settingsState = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      appBar: AppBar(
        title: Text('Audio & Equalizer', style: AppTypography.screenTitle),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Transparency Banner regarding Hardware Effects
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.elevatedSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded, color: AppColors.secondaryAccent, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hardware Audio Engine Notice', style: AppTypography.songTitleMedium),
                        const SizedBox(height: 4),
                        Text(
                          'Hardware equalization depends on Android OEM OpenSL ES DSP support. VYBE 3D maps your selected EQ profiles to software acoustic filters and gain shaping.',
                          style: AppTypography.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Presets Shelf
            Text('Presets', style: AppTypography.sectionHeading),
            const SizedBox(height: 12),
            SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _presets.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final preset = _presets[index];
                  final isSelected = settingsState.activePreset == preset;

                  return GestureDetector(
                    onTap: () {
                      ref.read(settingsProvider.notifier).applyPreset(preset);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryAccent : AppColors.elevatedSurface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? AppColors.primaryAccent : AppColors.glassBorder,
                        ),
                      ),
                      child: Text(
                        preset,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : AppColors.secondaryText,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 28),

            // 3-Band Graphic Sliders (Bass, Mid, Treble)
            Text('Frequency Shaping', style: AppTypography.sectionHeading),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.elevatedSurface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: Column(
                children: [
                  _buildEqSlider('Bass (60Hz)', settingsState.bassLevel, (val) {
                    ref.read(settingsProvider.notifier).setEqLevels(bass: val);
                  }),
                  const SizedBox(height: 12),
                  _buildEqSlider('Midrange (1kHz)', settingsState.midLevel, (val) {
                    ref.read(settingsProvider.notifier).setEqLevels(mid: val);
                  }),
                  const SizedBox(height: 12),
                  _buildEqSlider('Treble (14kHz)', settingsState.trebleLevel, (val) {
                    ref.read(settingsProvider.notifier).setEqLevels(treble: val);
                  }),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Playback Options
            Text('Playback Features', style: AppTypography.sectionHeading),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: AppColors.elevatedSurface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    activeColor: AppColors.secondaryAccent,
                    title: const Text('Auto-Resume Previous Session'),
                    subtitle: const Text('Restore previous song position when relaunching'),
                    value: settingsState.autoResume,
                    onChanged: (val) {
                      ref.read(settingsProvider.notifier).toggleAutoResume(val);
                    },
                  ),
                  const Divider(color: AppColors.divider),
                  SwitchListTile(
                    activeColor: AppColors.secondaryAccent,
                    title: const Text('Reduced Motion'),
                    subtitle: const Text('Disable continuous 3D floating and particle animations'),
                    value: settingsState.reducedMotion,
                    onChanged: (val) {
                      ref.read(settingsProvider.notifier).toggleReducedMotion(val);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Sleep Timer Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.elevatedSurface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: StreamBuilder<int>(
                stream: SleepTimerService.instance.remainingSecondsStream,
                initialData: SleepTimerService.instance.remainingSeconds,
                builder: (context, snapshot) {
                  final remaining = snapshot.data ?? 0;
                  final isActive = remaining > 0;

                  return Row(
                    children: [
                      const Icon(Icons.nightlight_round, color: AppColors.primaryAccent, size: 28),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Sleep Timer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            const SizedBox(height: 2),
                            Text(
                              isActive
                                  ? 'Active: ${remaining ~/ 60}m ${remaining % 60}s remaining'
                                  : 'Fades audio smoothly to zero',
                              style: AppTypography.metadata,
                            ),
                          ],
                        ),
                      ),
                      if (isActive)
                        TextButton(
                          onPressed: () {
                            SleepTimerService.instance.cancelTimer();
                          },
                          child: const Text('Cancel', style: TextStyle(color: AppColors.error)),
                        )
                      else
                        TextButton(
                          onPressed: () {
                            SleepTimerService.instance.startTimer(30);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Sleep timer set for 30 minutes')),
                            );
                          },
                          child: const Text('Start (30m)', style: TextStyle(color: AppColors.secondaryAccent)),
                        ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildEqSlider(String label, double value, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTypography.songTitleMedium.copyWith(fontSize: 14)),
            Text('${value > 0 ? '+' : ''}${value.toStringAsFixed(1)} dB', style: AppTypography.metadata),
          ],
        ),
        Slider(
          value: value,
          min: -10.0,
          max: 10.0,
          divisions: 20,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
