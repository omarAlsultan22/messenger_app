import 'package:flutter_test/flutter_test.dart';
import 'package:test_app/features/conversation/utils/format_time.dart';


void main() {
  group('getTime', () {
    test('formats single-digit hour without padding', () {
      final dateTime = DateTime(2024, 5, 1, 9, 5);

      final result = FormatTime.getTime(dateTime);

      // 9:05 — الساعة بدون padLeft، الدقيقة مع padLeft
      expect(result, '9:05');
    });

    test('formats double-digit hour', () {
      final dateTime = DateTime(2024, 5, 1, 14, 30);

      final result = FormatTime.getTime(dateTime);

      expect(result, '14:30');
    });

    test('pads single-digit minute with zero', () {
      final dateTime = DateTime(2024, 5, 1, 10, 5);

      final result = FormatTime.getTime(dateTime);

      expect(result, '10:05');
    });

    test('formats midnight correctly', () {
      final dateTime = DateTime(2024, 5, 1, 0, 0);

      final result = FormatTime.getTime(dateTime);

      expect(result, '0:00');
    });

    test('formats end of day correctly', () {
      final dateTime = DateTime(2024, 5, 1, 23, 59);

      final result = FormatTime.getTime(dateTime);

      expect(result, '23:59');
    });

    test('pads double-digit minute without extra padding', () {
      final dateTime = DateTime(2024, 5, 1, 10, 45);

      final result = FormatTime.getTime(dateTime);

      expect(result, '10:45');
    });
  });
}