import '../repositories/auth_repository.dart';
import 'package:test_app/core/services/session_service.dart';
import '../../../../core/data/data_sources/local/shared_preferences.dart';


class SignInUseCase {
  final AuthRepository _authRepository;

  SignInUseCase({
    required CacheHelper cacheHelper,
    required AuthRepository authRepository
  })
      :
        _authRepository = authRepository;

  Future<void> signInExecute({
    required String userEmail,
    required String userPassword,
  }) async {
    try {
      final userCredential = await _authRepository.signIn(
          userEmail: userEmail,
          userPassword: userPassword
      );
      final user = userCredential.user;
      // التحقق من وجود بريد إلكتروني وليس مستخدم مجهول
      if (user != null && user.email != null && !user.isAnonymous) {
        SessionService().login('NCSa42aEicXZF3JSq1JHzphgQZs2');
      }
    } catch (e) {
      rethrow;
    }
  }
}

