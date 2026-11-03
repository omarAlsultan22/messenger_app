import 'package:flutter_test/flutter_test.dart';
import 'package:test_app/shared/utils/format_duration.dart';


void main() {
  group('FormatDuration.getDuration', () {
    test('formats zero duration as 00:00', () {
      final result = FormatDuration.getDuration(Duration.zero);

      expect(result, '00:00');
    });

    test('formats duration less than a minute', () {
      final result = FormatDuration.getDuration(const Duration(seconds: 45));

      expect(result, '00:45');
    });

    test('formats duration with minutes and seconds', () {
      final result = FormatDuration.getDuration(
        const Duration(minutes: 2, seconds: 30),
      );

      expect(result, '02:30');
    });

    test('pads single-digit minutes and seconds', () {
      final result = FormatDuration.getDuration(
        const Duration(minutes: 5, seconds: 7),
      );

      expect(result, '05:07');
    });

    test('wraps minutes at 60 (remainder 60)', () {
      // 65 دقيقة → 5 دقائق (65 % 60 = 5)
      final result = FormatDuration.getDuration(const Duration(minutes: 65));

      expect(result, '05:00');
    });

    test('wraps seconds at 60 (remainder 60)', () {
      // 125 ثانية → 2 دقيقة و 5 ثواني
      final result = FormatDuration.getDuration(const Duration(seconds: 125));

      expect(result, '02:05');
    });

    test('formats exactly one hour as 00:00 (bug: hours ignored)', () {
      // 1 ساعة → 60 دقيقة → remainder(60) = 0 → 00:00
      final result = FormatDuration.getDuration(const Duration(hours: 1));

      expect(result, '00:00');
    });

    test('formats 90 minutes as 30:00 (bug: hours ignored)', () {
      // 90 دقيقة → remainder(60) = 30 → 30:00 (وليس 1:30:00)
      final result = FormatDuration.getDuration(const Duration(minutes: 90));

      expect(result, '30:00');
    });
  });
}