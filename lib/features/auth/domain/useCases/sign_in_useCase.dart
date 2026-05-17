import '../../../../core/networks/local/shared_preferences.dart';
import '../../../sign_in/domain/repositories/data_repository.dart';


class SignInUseCase {
  final DataRepository _authRepository;

  SignInUseCase({
    required DataRepository authRepository,
  })
      :
        _authRepository = authRepository;

  Future<void> signInExecute({
    required String phone,
  }) async {
    try {
      final doc = await _authRepository.signIn(
        phone: phone,
      );

      if (!doc.exists) {
        throw(Exception("User not found"));
      }

      final data = doc.data() as Map<String, dynamic>;
      final userPhone = data['userPhone'] as String;
      final userId = data['userId'] as String;

      if (phone != userPhone) {
        throw(Exception("Phone number does not match"));
      }
      CacheHelper.serStringValue(key: 'uId', value: userId);
    } catch (e) {
      rethrow;
    }
  }
}

