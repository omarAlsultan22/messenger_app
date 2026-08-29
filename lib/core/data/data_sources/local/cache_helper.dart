import 'package:shared_preferences/shared_preferences.dart';
import '../../../errors/exceptions/shared_prefs_app_exceptions.dart';


class CacheHelper {

  static final CacheHelper _instance = CacheHelper._internal();

  factory CacheHelper() => _instance;

  CacheHelper._internal();

  static late SharedPreferences sharedPreferences;

  Future<void> init() async {
    try {
      sharedPreferences = await SharedPreferences.getInstance();
    }
    catch (e) {
      throw SharedPrefsInitializeException(error: e);
    }
  }

  Future<bool> setString({
    required String key,
    required String value,
  }) async {
    try {
      return await sharedPreferences.setString(key, value);
    }
    catch (e) {
      throw SharedPrefsSaveException(error: e);
    }
  }

  Future<String> getString({
    required String key,
  }) async {
    try {
      return sharedPreferences.getString(key) ?? '';
    }
    catch (e) {
      throw SharedPrefsReadException(error: e);
    }
  }

  Future<bool> setBool({
    required String key,
    required bool value,
  }) async {
    try {
      return await sharedPreferences.setBool(key, value);
    }
    catch (e) {
      throw SharedPrefsSaveException(error: e);
    }
  }

  Future<bool?> getBool({
    required String key,
  }) async {
    try {
      return sharedPreferences.getBool(key);
    }
    catch (e) {
      throw SharedPrefsReadException(error: e);
    }
  }

  Future<bool> removeValue({
    required String key,
  }) async
  {
    try {
      return await sharedPreferences.remove(key);
    }
    catch (e) {
      throw SharedPrefsRemoveException(error: e);
    }
  }
}