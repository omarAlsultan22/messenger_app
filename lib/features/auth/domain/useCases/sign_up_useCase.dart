import '../repositories/auth_repository.dart';
import '../../../../core/data/models/user_model.dart';
import '../../../../core/data/data_sources/local/shared_preferences.dart';


class SignUpUseCase {
  final CacheHelper _cacheHelper;
  final AuthRepository _authRepository;
  final SettingsRepository _settingsRepository;

  SignUpUseCase({
    required CacheHelper cacheHelper,
    required AuthRepository authRepository,
    required SettingsRepository settingsRepository
  })
      :
        _cacheHelper = cacheHelper,
        _authRepository = authRepository,
        _settingsRepository = settingsRepository;

  Future<void> signUpExecute({
    required String userName,
    required String userEmail,
    required String userPassword,
  }) async {
    try {
      final userCredential = await _authRepository.signUp(
        userEmail: userEmail,
        userPassword: userPassword,
      );

      UserModel userModel = UserModel(
        userName: userName,
      );

      await _settingsRepository.createUserInfo(
          userModel: userModel, userCredential: userCredential);

      await _cacheHelper.setString(key: 'userName', value: userName);
    } catch (e) {
    rethrow;
    }
  }
}

