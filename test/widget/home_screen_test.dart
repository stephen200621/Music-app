import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../lib/animations/music_orb.dart';

void main() {
  group('Home Visuals Widget Tests', () {
    testWidgets('MusicOrb renders CustomPaint and handles tap events', (WidgetTester tester) async {
      bool orbTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: MusicOrb(
                size: 200,
                isPlaying: false,
                reducedMotion: true,
                onTap: () {
                  orbTapped = true;
                },
              ),
            ),
          ),
        ),
      );

      expect(find.byType(MusicOrb), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);

      await tester.tap(find.byType(MusicOrb));
      await tester.pump();

      expect(orbTapped, isTrue);
    });
  });
}
