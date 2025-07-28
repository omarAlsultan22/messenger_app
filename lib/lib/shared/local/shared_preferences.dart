import 'package:shared_preferences/shared_preferences.dart';

class CacheHelper {
  static late SharedPreferences sharedPreferences;

  static init() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  static Future<bool> serStringValue({
    required String key,
    required dynamic value
  }) async {
    return await sharedPreferences.setString(key, value);
  }

  static Future<String?> getStringValue({
    required String? key
  }) async {
    return sharedPreferences.getString(key!);
  }

  static Future<bool> serIntValue({
    required String key,
    required int value
  }) async {
    return await sharedPreferences.setInt(key, value);
  }

  static Future<int?> getIntValue({
    required String? key
  }) async {
    return sharedPreferences.getInt(key!);
  }

  static Future<bool> deleteStringValue({
    required String key
  }) async {
    return await sharedPreferences.remove(key);
  }

  static Future<bool> putBoolValue({
    required String key,
    required bool value
  }) async {
    return await sharedPreferences.setBool(key, value);
  }

  static Future<bool?> getBoolValue({
    required String? key
  }) async {
    return sharedPreferences.getBool(key!);
  }
}