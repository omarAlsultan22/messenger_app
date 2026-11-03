import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../../fakes/fake_cache_helper.dart';
import 'package:test_app/core/constants/app_colors.dart';
import 'package:test_app/features/conversation/domain/repositories/local_conversation_repository.dart';
import 'package:test_app/features/conversation/data/repositories_impl/local_conversation_repository_impl.dart';


void main() {
  late FakeCacheHelper fakeCache;
  late LocalConversationRepository repository;

  setUp(() {
    fakeCache = FakeCacheHelper();
    repository = LocalConversationRepositoryImpl(cacheHelper: fakeCache);
  });

  group('getSavedBackgroundColorAndImage', () {
    test('returns bgImage and bgColor from cache', () async {
      // نضع القيم في fakeCache
      await fakeCache.setString(
        key: 'bg_color_chat-1',
        value: '${AppColors.redPrimaryValue.value}',
      );
      await fakeCache.setString(
        key: 'bg_image_chat-1',
        value: 'https://example.com/bg.jpg',
      );

      final result = await repository.getSavedBackgroundColorAndImage(
        docId: 'chat-1',
      );

      expect(result['bgImage'], 'https://example.com/bg.jpg');
      expect(result['bgColor'], isA<Color>());
      expect(result['bgColor'], AppColors.redPrimaryValue);
    });

    test('uses the correct cache keys with docId suffix', () async {
      // نضع قيم في مفاتيح مختلفة — يجب ألا تُقرأ
      await fakeCache.setString(key: 'bg_color_other', value: '0xFFFF0000');
      await fakeCache.setString(key: 'bg_image_other', value: 'other.jpg');

      // مفتاح chat-1 فارغ → colorValue = '' → int.parse يرمي
      expect(
            () => repository.getSavedBackgroundColorAndImage(docId: 'chat-1'),
        throwsA(isA<FormatException>()),
      );

      // المفاتيح الصحيحة لم تُقرأ
      expect(await fakeCache.getString(key: 'bg_color_chat-1'), '');
    });

    test('throws FormatException when colorValue is empty', () async {
      // لا نضع أي قيمة — getString يعيد ''
      expect(
            () => repository.getSavedBackgroundColorAndImage(docId: 'chat-1'),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws FormatException when colorValue is non-numeric', () async {
      await fakeCache.setString(key: 'bg_color_chat-1', value: 'not-a-color');

      expect(
            () => repository.getSavedBackgroundColorAndImage(docId: 'chat-1'),
        throwsA(isA<FormatException>()),
      );
    });
  });
}