import '../../../fakes/fake_cache_helper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_app/core/services/data/session_service.dart';


void main() {
  late SessionService session;
  late FakeCacheHelper fakeCache;

  setUp(() {
    fakeCache = FakeCacheHelper();
    session = SessionService(cacheHelper: fakeCache);
  });

  group('initial state', () {
    test('currentUid is empty on creation', () {
      expect(session.currentUid, '');
    });

    test('isLoggedIn is false on creation', () {
      expect(session.isLoggedIn, false);
    });
  });

  group('loadFromStorage', () {
    test('loads uid from cache when present', () async {
      await fakeCache.setString(key: 'user_id', value: 'uid-123');

      await session.loadFromStorage();

      expect(session.currentUid, 'uid-123');
      expect(session.isLoggedIn, true);
    });

    test('sets empty uid when cache is empty', () async {
      // لا نضع شيئاً في fakeCache
      await session.loadFromStorage();

      expect(session.currentUid, '');
      expect(session.isLoggedIn, false);
    });

    test('reads from the "user_id" key', () async {
      // نضع قيمة في مفتاح مختلف — يجب ألا تُقرأ
      await fakeCache.setString(key: 'other_key', value: 'other-uid');

      await session.loadFromStorage();

      expect(session.currentUid, '');
    });
  });

  group('login', () {
    test('updates currentUid and saves to cache', () async {
      await session.login('uid-456');

      expect(session.currentUid, 'uid-456');
      expect(session.isLoggedIn, true);
      expect(await fakeCache.getString(key: 'user_id'), 'uid-456');
    });

    test('overwrites previous uid', () async {
      await session.login('uid-1');
      await session.login('uid-2');

      expect(session.currentUid, 'uid-2');
      expect(await fakeCache.getString(key: 'user_id'), 'uid-2');
    });

    test('propagates cache write errors', () async {
      // نجعل fakeCache يرمي — انظر FakeCacheHelper أدناه
      fakeCache.setStringError = Exception('disk full');

      expect(
            () => session.login('uid-1'),
        throwsA(isA<Exception>()),
      );

      // currentUid تم تحديثه قبل الفشل (سلوك الكود الحالي)
      expect(session.currentUid, 'uid-1');
    });
  });

  group('logout', () {
    test('clears currentUid and removes from cache', () async {
      await session.login('uid-123');
      await session.logout();

      expect(session.currentUid, '');
      expect(session.isLoggedIn, false);
      expect(await fakeCache.getString(key: 'user_id'), isNull);
    });

    test('logout when already logged out is safe', () async {
      await session.logout();

      expect(session.currentUid, '');
      expect(session.isLoggedIn, false);
    });
  });
}