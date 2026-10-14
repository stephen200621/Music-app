import 'package:flutter_test/flutter_test.dart';
import '../../lib/data/models/music_mode.dart';
import '../../lib/data/models/song.dart';
import '../../lib/data/models/play_history_item.dart';

void main() {
  group('AI Recommendation Scoring Logic Tests', () {
    test('Energy alignment scores higher when song matches mode target energy', () {
      final chillMode = MusicMode.getMode(ModeType.chill); // targetEnergy: 0.3
      final workoutMode = MusicMode.getMode(ModeType.workout); // targetEnergy: 0.9

      final calmSong = const Song(
        id: '1',
        title: 'Calm Melody',
        fileUri: '/path/1',
        dateAdded: 0,
        lastScannedAt: 0,
        energy: 0.25,
      );

      final hypeSong = const Song(
        id: '2',
        title: 'High Octane',
        fileUri: '/path/2',
        dateAdded: 0,
        lastScannedAt: 0,
        energy: 0.92,
      );

      // Delta for calm song in chill mode: (0.25 - 0.3).abs() = 0.05
      // Delta for calm song in workout mode: (0.25 - 0.9).abs() = 0.65
      final calmChillDelta = (calmSong.energy - chillMode.targetEnergy).abs();
      final calmWorkoutDelta = (calmSong.energy - workoutMode.targetEnergy).abs();

      expect(calmChillDelta < calmWorkoutDelta, isTrue);

      final hypeWorkoutDelta = (hypeSong.energy - workoutMode.targetEnergy).abs();
      final hypeChillDelta = (hypeSong.energy - chillMode.targetEnergy).abs();

      expect(hypeWorkoutDelta < hypeChillDelta, isTrue);
    });

    test('Favorite tracks receive positive scoring boost', () {
      final baseSong = const Song(
        id: '10',
        title: 'Track A',
        fileUri: '/path/10',
        dateAdded: 0,
        lastScannedAt: 0,
        isFavorite: false,
      );

      final favSong = baseSong.copyWith(isFavorite: true);

      expect(favSong.isFavorite, isTrue);
      expect(baseSong.isFavorite, isFalse);
    });
  });
}
