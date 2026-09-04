import '../repositories/auth_repository.dart';
import '../repositories/sign_up_repository.dart';
import '../../../../core/data/models/user_model.dart';
import 'package:test_app/core/services/session_service.dart';


class SignUpUseCase {
  final SessionService _sessionService;
  final AuthRepository _authRepository;
  final SignUpRepository _signUpRepository;

  SignUpUseCase({
    required SessionService sessionService,
    required AuthRepository authRepository,
    required SignUpRepository signUpRepository
  })
      :
        _sessionService = sessionService,
        _authRepository = authRepository,
        _signUpRepository = signUpRepository;

  Future<void> signUpExecute({
    required String firstName,
    required String lastName,
    required String userEmail,
    required String userPassword,
  }) async {
    try {
      final userCredential = await _authRepository.signUp(
        userEmail: userEmail,
        userPassword: userPassword,
      );

      final user = userCredential.user;
      if (user != null && user.email != null && !user.isAnonymous) {
        UserModel userModel = UserModel(
            userId: _sessionService.currentUid,
            firstName: firstName,
            lastName: lastName,
            fullName: '$firstName''$lastName'
        );

        await _signUpRepository.createUserInfo(
            userModel: userModel
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}

