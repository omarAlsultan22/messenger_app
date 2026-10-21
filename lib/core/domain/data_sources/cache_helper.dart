abstract class CacheHelper {
  Future<void> init();

  Future<bool> setString({
    required String key,
    required String value,
  });

  Future<String> getString({
    required String key,
  });

  Future<bool> setBool({
    required String key,
    required bool value,
  });

  Future<bool?> getBool({
    required String key,
  });

  Future<bool> removeValue({
    required String key,
  });
}