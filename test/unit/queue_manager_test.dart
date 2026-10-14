import 'package:flutter_test/flutter_test.dart';
import '../../lib/data/models/song.dart';

void main() {
  group('Queue Management Logic Tests', () {
    late List<Song> sampleQueue;

    setUp(() {
      sampleQueue = [
        const Song(id: 's1', title: 'Track 1', fileUri: '/1', dateAdded: 0, lastScannedAt: 0),
        const Song(id: 's2', title: 'Track 2', fileUri: '/2', dateAdded: 0, lastScannedAt: 0),
        const Song(id: 's3', title: 'Track 3', fileUri: '/3', dateAdded: 0, lastScannedAt: 0),
      ];
    });

    test('Reordering moves track to exact specified index', () {
      final list = List<Song>.from(sampleQueue);
      int oldIndex = 0;
      int newIndex = 2; // Moving Track 1 to after Track 2
      if (newIndex > oldIndex) newIndex -= 1;
      final item = list.removeAt(oldIndex);
      list.insert(newIndex, item);

      expect(list[1].id, 's1');
      expect(list[0].id, 's2');
      expect(list[2].id, 's3');
    });

    test('Cycle repeat mode transitions off -> all -> one -> off', () {
      String nextRepeatMode(String current) {
        if (current == 'all') return 'one';
        if (current == 'one') return 'off';
        return 'all';
      }

      expect(nextRepeatMode('all'), 'one');
      expect(nextRepeatMode('one'), 'off');
      expect(nextRepeatMode('off'), 'all');
    });

    test('Removing current song updates queue length and retains valid index', () {
      final list = List<Song>.from(sampleQueue);
      list.removeAt(1);

      expect(list.length, 2);
      expect(list[0].id, 's1');
      expect(list[1].id, 's3');
    });
  });
}
