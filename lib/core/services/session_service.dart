import '../di/service _locator.dart';
import '../data/data_sources/local/cache_helper.dart';


class SessionService {

  static final SessionService _instance = SessionService._internal();

  factory SessionService() => _instance;

  SessionService._internal();

  static final _cacheHelper = sl<CacheHelper>();

  static const _uId = 'user_id';

  String _currentUid = '';

  String get currentUid => _currentUid;

  bool get isLoggedIn => _currentUid.isNotEmpty;

  Future<void> loadFromStorage() async {
    _currentUid = await _cacheHelper.getString(key: _uId);
  }

  Future<void> login(String uid) async {
    _currentUid = uid;

    await _cacheHelper.setString(key: _uId, value: uid);
  }

  Future<void> logout() async {
    _currentUid = '';

    await _cacheHelper.removeValue(key: _uId);
  }
}
