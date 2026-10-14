import 'package:flutter_test/flutter_test.dart';
import '../../lib/data/models/music_mode.dart';

void main() {
  group('Music Mode Specification Tests', () {
    test('Contains exactly 6 distinct music modes', () {
      expect(MusicMode.allModes.length, 6);
      final types = MusicMode.allModes.map((m) => m.type).toSet();
      expect(types.contains(ModeType.chill), isTrue);
      expect(types.contains(ModeType.focus), isTrue);
      expect(types.contains(ModeType.workout), isTrue);
      expect(types.contains(ModeType.sleep), isTrue);
      expect(types.contains(ModeType.party), isTrue);
      expect(types.contains(ModeType.custom), isTrue);
    });

    test('Energy levels match mood intent', () {
      final sleep = MusicMode.getMode(ModeType.sleep);
      final chill = MusicMode.getMode(ModeType.chill);
      final workout = MusicMode.getMode(ModeType.workout);
      final party = MusicMode.getMode(ModeType.party);

      expect(sleep.targetEnergy <= 0.20, isTrue);
      expect(chill.targetEnergy <= 0.35, isTrue);
      expect(workout.targetEnergy >= 0.85, isTrue);
      expect(party.targetEnergy >= 0.90, isTrue);
    });

    test('Animation speed multipliers reflect atmospheric pace', () {
      final sleep = MusicMode.getMode(ModeType.sleep);
      final party = MusicMode.getMode(ModeType.party);

      expect(sleep.animationSpeedMultiplier < 0.5, isTrue);
      expect(party.animationSpeedMultiplier > 1.2, isTrue);
    });
  });
}
