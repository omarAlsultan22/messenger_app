import 'package:test_app/core/data/data_sources/local/shared_preferences.dart';


class SessionService {
  static final SessionService _instance = SessionService._internal();

  factory SessionService() => _instance;

  SessionService._internal();

  static final _cacheHelper = CacheHelper();

  String _currentUid = '';

  String get currentUid => _currentUid;

  bool get isLoggedIn => _currentUid.isNotEmpty;

  Future<void> loadFromStorage() async {
    _currentUid = await _cacheHelper.getString(key: 'user_id');
  }

  Future<void> login(String uid) async {
    _currentUid = uid;

    await _cacheHelper.setString(key: 'user_id', value: uid);
  }

  Future<void> logout() async {
    _currentUid = '';

    await _cacheHelper.removeValue(key: 'user_id');
  }
}
