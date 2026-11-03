import '../../domain/data_sources/cache_helper.dart';


class SessionService {
  static SessionService? _instance;

  factory SessionService({required CacheHelper cacheHelper}) {
    _instance ??= SessionService._internal(cacheHelper);
    return _instance!;
  }

  SessionService._internal(this._cacheHelper);

  final CacheHelper _cacheHelper;

  String _currentUid = '';

  static const _uId = 'user_id';

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
