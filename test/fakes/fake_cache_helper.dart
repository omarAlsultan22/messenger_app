import 'package:test_app/core/domain/data_sources/cache_helper.dart';


class FakeCacheHelper implements CacheHelper {
  final Map<String, dynamic> _storage = {};

  // للتحكم في الأخطاء
  Object? setStringError;
  Object? getStringError;
  Object? removeValueError;

  @override
  Future<bool> setString({required String key, required String value}) async {
    if (setStringError != null) throw setStringError!;
    _storage[key] = value;
    return true;
  }

  @override
  Future<String> getString({required String key}) async {
    if (getStringError != null) throw getStringError!;
    return _storage[key] as String? ?? '';
  }

  @override
  Future<bool> setBool({required String key, required bool value}) async {
    _storage[key] = value;
    return true;
  }

  @override
  Future<bool> getBool({required String key}) async {
    return _storage[key];
  }

  @override
  Future<bool> removeValue({required String key}) async {
    if (removeValueError != null) throw removeValueError!;
    _storage.remove(key);
    return true;
  }
}