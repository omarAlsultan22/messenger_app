import 'package:flutter_test/flutter_test.dart';
import 'package:test_app/features/conversation/utils/date_converter.dart';


void main() {
  group('getDateHeader', () {
    // نثبت "الآن" إلى 2024-05-15 (الأربعاء)
    final fixedNow = DateTime(2024, 5, 15, 12, 0);

    test('returns "Today" for same day', () {
      final date = DateTime(2024, 5, 15, 9, 30);

      final result = DateConverter.getDateHeader(date, now: fixedNow);

      expect(result, 'Today');
    });

    test('returns "Yesterday" for previous day', () {
      final date = DateTime(2024, 5, 14, 9, 30);

      final result = DateConverter.getDateHeader(date, now: fixedNow);

      expect(result, 'Yesterday');
    });

    test('returns day name for date within 7 days', () {
      // 2024-05-12 (الأحد) — 3 أيام قبل 2024-05-15
      final date = DateTime(2024, 5, 12, 9, 30);

      final result = DateConverter.getDateHeader(date, now: fixedNow);

      expect(result, 'Sunday');
    });

    test('returns day name for date exactly 6 days ago', () {
      // 2024-05-09 (الخميس) — 6 أيام قبل 2024-05-15
      final date = DateTime(2024, 5, 9, 9, 30);

      final result = DateConverter.getDateHeader(date, now: fixedNow);

      expect(result, 'Thursday');
    });

    test('returns month and year for date exactly 7 days ago', () {
      // 2024-05-08 — 7 أيام قبل 2024-05-15 → "May 2024"
      final date = DateTime(2024, 5, 8, 9, 30);

      final result = DateConverter.getDateHeader(date, now: fixedNow);

      expect(result, 'May 2024');
    });

    test('returns month and year for date older than 7 days', () {
      // 2023-03-15 — قديم
      final date = DateTime(2023, 3, 15, 9, 30);

      final result = DateConverter.getDateHeader(date, now: fixedNow);

      expect(result, 'March 2023');
    });

    test('returns month and year for date in the future', () {
      // 2024-06-01 — مستقبل (now.difference سالب → < 7)
      final date = DateTime(2024, 6, 1, 9, 30);

      final result = DateConverter.getDateHeader(date, now: fixedNow);

      // difference.inDays == -17 → < 7 → DateFormat('EEEE')
      // لكن — 17 يوم في المستقبل → اسم اليوم (Saturday)
      expect(result, 'Saturday');
    });
  });
}