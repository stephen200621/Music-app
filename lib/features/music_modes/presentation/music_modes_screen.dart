import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../animations/perspective_card.dart';
import '../../../app/providers/mode_provider.dart';
import '../../../app/providers/recommendation_provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../data/models/music_mode.dart';
import '../../../services/sleep_timer/sleep_timer_service.dart';

class MusicModesScreen extends ConsumerStatefulWidget {
  const MusicModesScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MusicModesScreen> createState() => _MusicModesScreenState();
}

class _MusicModesScreenState extends ConsumerState<MusicModesScreen> {
  int _sleepMinutes = 30;

  @override
  Widget build(BuildContext context) {
    final currentMode = ref.watch(modeProvider);

    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      appBar: AppBar(
        title: Text('Music Modes', style: AppTypography.screenTitle),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select an atmosphere to calibrate the AI recommendation bias and visual dynamics.',
              style: AppTypography.bodyMedium,
            ),
            const SizedBox(height: 20),

            // Mode Cards List
            ...MusicMode.allModes.map((mode) {
              final isSelected = mode.type == currentMode.type;

              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: PerspectiveCard(
                  onTap: () {
                    ref.read(modeProvider.notifier).selectMode(mode);
                    ref.read(recommendationProvider.notifier).recalculateRecommendations();
                  },
                  borderRadius: 22,
                  padding: const EdgeInsets.all(18),
                  gradient: LinearGradient(
                    colors: [
                      isSelected ? mode.primaryColor.withOpacity(0.35) : AppColors.elevatedSurface,
                      isSelected ? mode.secondaryColor.withOpacity(0.2) : AppColors.secondaryBackground,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: isSelected ? mode.primaryColor : AppColors.glassBorder,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: mode.primaryColor.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 1,
                          )
                        ]
                      : null,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: mode.primaryColor.withOpacity(0.25),
                            ),
                            child: Icon(mode.icon, color: mode.primaryColor, size: 28),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      mode.title,
                                      style: AppTypography.songTitleMedium.copyWith(
                                        fontSize: 18,
                                        color: isSelected ? Colors.white : AppColors.mainText,
                                      ),
                                    ),
                                    if (isSelected) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: mode.primaryColor,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: const Text(
                                          'ACTIVE',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  mode.description,
                                  style: AppTypography.artistNameMedium,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Energy Level Indicator Bar
                      Row(
                        children: [
                          Text('Energy Bias', style: AppTypography.metadata),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: mode.targetEnergy,
                                backgroundColor: Colors.white.withOpacity(0.08),
                                valueColor: AlwaysStoppedAnimation<Color>(mode.primaryColor),
                                minHeight: 5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text('${(mode.targetEnergy * 100).toInt()}%', style: AppTypography.metadata),
                        ],
                      ),

                      // Special Features (Sleep Timer in Sleep mode, Focus Timer in Focus mode)
                      if (mode.type == ModeType.sleep && isSelected) ...[
                        const SizedBox(height: 14),
                        const Divider(color: AppColors.divider),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Sleep Fadeout Timer:'),
                            DropdownButton<int>(
                              value: _sleepMinutes,
                              dropdownColor: AppColors.secondaryBackground,
                              underline: const SizedBox(),
                              items: const [
                                DropdownMenuItem(value: 15, child: Text('15 Minutes')),
                                DropdownMenuItem(value: 30, child: Text('30 Minutes')),
                                DropdownMenuItem(value: 45, child: Text('45 Minutes')),
                                DropdownMenuItem(value: 60, child: Text('60 Minutes')),
                              ],
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _sleepMinutes = val);
                                  SleepTimerService.instance.startTimer(val);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Sleep timer set for $val minutes')),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
