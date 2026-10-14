import 'package:flutter/material.dart';

enum ModeType {
  chill,
  focus,
  workout,
  sleep,
  party,
  custom;

  static ModeType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'focus':
        return ModeType.focus;
      case 'workout':
        return ModeType.workout;
      case 'sleep':
        return ModeType.sleep;
      case 'party':
        return ModeType.party;
      case 'custom':
        return ModeType.custom;
      default:
        return ModeType.chill;
    }
  }
}

class MusicMode {
  final ModeType type;
  final String title;
  final String description;
  final IconData icon;
  final Color primaryColor;
  final Color secondaryColor;
  final double targetEnergy; // 0.0 (super calm) to 1.0 (intense)
  final double animationSpeedMultiplier;

  const MusicMode({
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
    required this.primaryColor,
    required this.secondaryColor,
    required this.targetEnergy,
    required this.animationSpeedMultiplier,
  });

  static const List<MusicMode> allModes = [
    MusicMode(
      type: ModeType.chill,
      title: 'CHILL',
      description: 'Mellow, low-energy acoustics & ambient atmosphere',
      icon: Icons.spa_rounded,
      primaryColor: Color(0xFF9B5CFF),
      secondaryColor: Color(0xFF7000FF),
      targetEnergy: 0.3,
      animationSpeedMultiplier: 0.7,
    ),
    MusicMode(
      type: ModeType.focus,
      title: 'FOCUS',
      description: 'Zero distraction, instrumental soundscapes & timer',
      icon: Icons.psychology_rounded,
      primaryColor: Color(0xFF00D9FF),
      secondaryColor: Color(0xFF0077FF),
      targetEnergy: 0.4,
      animationSpeedMultiplier: 0.5,
    ),
    MusicMode(
      type: ModeType.workout,
      title: 'WORKOUT',
      description: 'High-tempo adrenaline, driving rhythm & pace',
      icon: Icons.bolt_rounded,
      primaryColor: Color(0xFFFF5CC8),
      secondaryColor: Color(0xFFFF0055),
      targetEnergy: 0.9,
      animationSpeedMultiplier: 1.4,
    ),
    MusicMode(
      type: ModeType.sleep,
      title: 'SLEEP',
      description: 'Gentle lulling tones with auto fade-out sleep timer',
      icon: Icons.nightlight_round,
      primaryColor: Color(0xFF6C63FF),
      secondaryColor: Color(0xFF2A2859),
      targetEnergy: 0.15,
      animationSpeedMultiplier: 0.3,
    ),
    MusicMode(
      type: ModeType.party,
      title: 'PARTY',
      description: 'Electrifying bangers, bass heavy & euphoric vibing',
      icon: Icons.celebration_rounded,
      primaryColor: Color(0xFFFF007A),
      secondaryColor: Color(0xFFFFB300),
      targetEnergy: 0.95,
      animationSpeedMultiplier: 1.5,
    ),
    MusicMode(
      type: ModeType.custom,
      title: 'CUSTOM',
      description: 'Tailor your energy level and personalized genre weights',
      icon: Icons.tune_rounded,
      primaryColor: Color(0xFF54E6A5),
      secondaryColor: Color(0xFF00B4D8),
      targetEnergy: 0.6,
      animationSpeedMultiplier: 1.0,
    ),
  ];

  static MusicMode getMode(ModeType type) {
    return allModes.firstWhere((m) => m.type == type, orElse: () => allModes.first);
  }
}
