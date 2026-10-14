import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../lib/shared_widgets/custom_icon_button.dart';

void main() {
  group('Player Controls Widget Tests', () {
    testWidgets('CustomIconButton renders icon and triggers callback on tap', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomIconButton(
              icon: Icons.play_arrow_rounded,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);

      await tester.tap(find.byType(CustomIconButton));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });
}
