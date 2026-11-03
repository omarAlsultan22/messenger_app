import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_app/core/domain/data_sources/cache_helper.dart';
import 'package:test_app/core/data/data_sources/local/cache_helper_impl.dart';


void main() {
  late CacheHelper cacheHelper;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    cacheHelper = CacheHelperImpl(prefs: prefs);
  });

  group('CacheHelperImpl - String', () {
    test('setString saves and getString returns the same value', () async {
      final saved = await cacheHelper.setString(key: 'token', value: 'abc123');
      expect(saved, true);

      final result = await cacheHelper.getString(key: 'token');
      expect(result, 'abc123');
    });

    test('getString returns empty string when key does not exist', () async {
      final result = await cacheHelper.getString(key: 'missing');
      expect(result, '');
    });

    test('setString overwrites existing value', () async {
      await cacheHelper.setString(key: 'token', value: 'old');
      await cacheHelper.setString(key: 'token', value: 'new');

      expect(await cacheHelper.getString(key: 'token'), 'new');
    });
  });

  group('CacheHelperImpl - Bool', () {
    test('setBool saves and getBool returns the same value', () async {
      final saved = await cacheHelper.setBool(key: 'isDark', value: true);
      expect(saved, true);

      final result = await cacheHelper.getBool(key: 'isDark');
      expect(result, true);
    });

    test('getBool returns null when key does not exist', () async {
      final result = await cacheHelper.getBool(key: 'missing');
      expect(result, isNull);
    });

    test('setBool overwrites existing value', () async {
      await cacheHelper.setBool(key: 'isDark', value: true);
      await cacheHelper.setBool(key: 'isDark', value: false);

      expect(await cacheHelper.getBool(key: 'isDark'), false);
    });
  });

  group('CacheHelperImpl - removeValue', () {
    test('removeValue deletes the key', () async {
      await cacheHelper.setString(key: 'token', value: 'abc');
      final removed = await cacheHelper.removeValue(key: 'token');
      expect(removed, true);

      expect(await cacheHelper.getString(key: 'token'), '');
    });

    test('removeValue returns false when key does not exist', () async {
      final removed = await cacheHelper.removeValue(key: 'missing');
      expect(removed, false);
    });
  });

  group('CacheHelperImpl - independence', () {
    test('string and bool with same key do not interfere', () async {
      await cacheHelper.setString(key: 'k', value: 'text');
      await cacheHelper.setBool(key: 'k', value: true);

      expect(await cacheHelper.getString(key: 'k'), 'text');
      expect(await cacheHelper.getBool(key: 'k'), true);
    });

    test('different keys are independent', () async {
      await cacheHelper.setString(key: 'a', value: 'A');
      await cacheHelper.setString(key: 'b', value: 'B');

      expect(await cacheHelper.getString(key: 'a'), 'A');
      expect(await cacheHelper.getString(key: 'b'), 'B');
    });
  });
}