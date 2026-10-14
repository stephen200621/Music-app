import 'package:flutter_test/flutter_test.dart';
import '../../lib/core/constants/app_constants.dart';
import '../../lib/core/utils/time_formatter.dart';
import '../../lib/data/models/play_history_item.dart';

void main() {
  group('History Tracking & Date Grouping Tests', () {
    test('Calculates completion percentage correctly', () {
      final totalMs = 200000;
      final listenedMs = 160000; // 80%
      final completion = ((listenedMs / totalMs) * 100).clamp(0, 100).round();

      expect(completion, 80);
      expect(completion >= AppConstants.minCompletionPercentage, isTrue);
    });

    test('Identifies early skips under skip threshold', () {
      final skippedDurationMs = 12000; // 12 seconds
      final isEarlySkip = skippedDurationMs < AppConstants.skipThresholdMs;

      expect(isEarlySkip, isTrue);
    });

    test('Date grouping returns Today for current timestamp', () {
      final now = DateTime.now().millisecondsSinceEpoch;
      final group = TimeFormatter.getDateGrouping(now);

      expect(group, 'Today');
    });

    test('Date grouping returns Yesterday for 24-48 hours ago', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1)).millisecondsSinceEpoch;
      final group = TimeFormatter.getDateGrouping(yesterday);

      expect(group, 'Yesterday');
    });

    test('TimeFormatter formats milliseconds to mm:ss', () {
      expect(TimeFormatter.formatMs(0), '00:00');
      expect(TimeFormatter.formatMs(65000), '01:05');
      expect(TimeFormatter.formatMs(3600000), '1:00:00');
    });
  });
}
