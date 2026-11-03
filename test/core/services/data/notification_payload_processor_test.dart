import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_app/core/services/data/notification_service.dart';


void main() {
  late NotificationService service;

  setUp(() {
    // Singleton — لكن الدوال النقية لا تتأثر بالحالة
    service = NotificationService();
  });

  group('processPayload', () {
    test('leaves primitive values unchanged', () {
      final result = service.processPayload({
        'a': 1,
        'b': 'text',
        'c': true,
        'd': null,
      });

      expect(result, {'a': 1, 'b': 'text', 'c': true, 'd': null});
    });

    test('converts DateTime to ISO8601 string', () {
      final date = DateTime(2024, 5, 1, 12, 30);
      final result = service.processPayload({'date': date});

      expect(result['date'], date.toIso8601String());
      expect(result['date'], isA<String>());
    });

    test('converts Timestamp to ISO8601 string', () {
      final date = DateTime(2024, 5, 1, 12, 30);
      final timestamp = Timestamp.fromDate(date);
      final result = service.processPayload({'ts': timestamp});

      expect(result['ts'], date.toIso8601String());
    });

    test('processes nested Map recursively', () {
      final date = DateTime(2024);
      final result = service.processPayload({
        'nested': {'inner': date, 'keep': 'value'},
      });

      expect(result['nested'], {
        'inner': date.toIso8601String(),
        'keep': 'value',
      });
    });

    test('processes List with DateTime and Timestamp items', () {
      final date = DateTime(2024);
      final result = service.processPayload({
        'items': [date, Timestamp.fromDate(date), 'plain', 42],
      });

      expect(result['items'], [
        date.toIso8601String(),
        date.toIso8601String(),
        'plain',
        42,
      ]);
    });

    test('processes List of Maps recursively', () {
      final date = DateTime(2024);
      final result = service.processPayload({
        'items': [
          {'when': date},
          {'when': Timestamp.fromDate(date)},
        ],
      });

      expect(result['items'], [
        {'when': date.toIso8601String()},
        {'when': date.toIso8601String()},
      ]);
    });

    test('result is JSON-encodable', () {
      final date = DateTime(2024);
      final result = service.processPayload({
        'date': date,
        'ts': Timestamp.fromDate(date),
        'nested': {'inner': date},
        'list': [Timestamp.fromDate(date)],
      });

      expect(() => jsonEncode(result), returnsNormally);
    });
  });
}