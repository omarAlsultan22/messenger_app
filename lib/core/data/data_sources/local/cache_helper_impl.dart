import '../../../domain/data_sources/cache_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../errors/exceptions/shared_prefs_app_exceptions.dart';


class CacheHelperImpl implements CacheHelper {
  final SharedPreferences _prefs;

  CacheHelperImpl({required SharedPreferences prefs}) : _prefs = prefs;

  @override
  Future<bool> setString({
    required String key,
    required String value,
  }) async {
    try {
      return await _prefs.setString(key, value);
    }
    catch (e) {
      throw SharedPrefsSaveException(error: e);
    }
  }

  @override
  Future<String> getString({
    required String key,
  }) async {
    try {
      return _prefs.getString(key) ?? '';
    }
    catch (e) {
      throw SharedPrefsReadException(error: e);
    }
  }

  @override
  Future<bool> setBool({
    required String key,
    required bool value,
  }) async {
    try {
      return await _prefs.setBool(key, value);
    }
    catch (e) {
      throw SharedPrefsSaveException(error: e);
    }
  }

  @override
  Future<bool?> getBool({
    required String key,
  }) async {
    try {
      return _prefs.getBool(key);
    }
    catch (e) {
      throw SharedPrefsReadException(error: e);
    }
  }

  @override
  Future<bool> removeValue({
    required String key,
  }) async
  {
    try {
      return await _prefs.remove(key);
    }
    catch (e) {
      throw SharedPrefsRemoveException(error: e);
    }
  }
}