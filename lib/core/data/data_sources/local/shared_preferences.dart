import 'package:shared_preferences/shared_preferences.dart';


class CacheHelper {

  static final CacheHelper _instance = CacheHelper._internal();

  factory CacheHelper() => _instance;

  CacheHelper._internal();

  static late SharedPreferences sharedPreferences;

  Future<void> init() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  Future<bool> setString({
    required String key,
    required String value,
  }) async {
    return await sharedPreferences.setString(key, value);
  }

  Future<String> getString({
    required String key,
  }) async {
    return sharedPreferences.getString(key) ?? '';
  }

  Future<bool> setBool({
    required String key,
    required bool value,
  }) async {
    return await sharedPreferences.setBool(key, value);
  }

  Future<bool?> getBool({
    required String key,
  }) async {
    return sharedPreferences.getBool(key);
  }

  Future<bool> removeValue({
    required String key,
  }) async
  {
    return await sharedPreferences.remove(key);
  }
}