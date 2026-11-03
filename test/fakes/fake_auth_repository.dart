import 'package:firebase_auth/firebase_auth.dart';
import 'package:test_app/features/auth/domain/repositories/auth_repository.dart';


class FakeAuthRepository implements AuthRepository {
  // ===== signIn =====
  UserCredential? signInResult;
  Object? signInError;
  int signInCallCount = 0;
  String? lastSignInEmail;
  String? lastSignInPassword;

  // ===== signUp =====
  UserCredential? signUpResult;
  Object? signUpError;
  int signUpCallCount = 0;
  String? lastSignUpEmail;
  String? lastSignUpPassword;

  @override
  Future<UserCredential> signUp({
    required String userEmail,
    required String userPassword,
  }) async {
    signUpCallCount++;
    lastSignUpEmail = userEmail;
    lastSignUpPassword = userPassword;
    if (signUpError != null) throw signUpError!;
    return signUpResult!;
  }

  // ===== updateProfile =====
  User? updateProfileResult;
  Object? updateProfileError;
  int updateProfileCallCount = 0;
  String? lastNewEmail;
  String? lastCurrentPassword;
  String? lastNewPassword;

  @override
  Future<UserCredential> signIn({
    required String userEmail,
    required String userPassword,
  }) async {
    signInCallCount++;
    lastSignInEmail = userEmail;
    lastSignInPassword = userPassword;
    if (signInError != null) throw signInError!;
    return signInResult!;
  }

  @override
  Future<User?> updateProfile({
    required String newEmail,
    required String currentPassword,
    required String newPassword,
  }) async {
    updateProfileCallCount++;
    lastNewEmail = newEmail;
    lastCurrentPassword = currentPassword;
    lastNewPassword = newPassword;
    if (updateProfileError != null) throw updateProfileError!;
    return updateProfileResult;
  }

  // باقي دوال AuthRepository — لا يحتاجها أي UseCase حالياً
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(
        'FakeAuthRepository.${invocation.memberName} not stubbed',
      );
}