import '../repositories/auth_repository.dart';
import 'package:test_app/core/services/session_service.dart';


class SignInUseCase {
  final AuthRepository _authRepository;
  final SessionService _sessionService;

  SignInUseCase({
    required SessionService sessionService,
    required AuthRepository authRepository
  })
      : _sessionService = sessionService,
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
      if (user != null && user.email != null && !user.isAnonymous) {
        _sessionService.login('NCSa42aEicXZF3JSq1JHzphgQZs2');
      }
    } catch (e) {
      rethrow;
    }
  }
}

