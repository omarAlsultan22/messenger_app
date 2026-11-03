import 'package:firebase_auth/firebase_auth.dart';
import 'package:test_app/core/domain/data_sources/auth_service.dart';


class FakeAuthService implements AuthService {
  // ===== signIn =====
  UserCredential? signInResult;
  Object? signInError;
  int signInCallCount = 0;
  String? lastSignInEmail;
  String? lastSignInPassword;

  @override
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    signInCallCount++;
    lastSignInEmail = email;
    lastSignInPassword = password;
    if (signInError != null) throw signInError!;
    return signInResult!;
  }

  // ===== signUp =====
  UserCredential? signUpResult;
  Object? signUpError;
  int signUpCallCount = 0;
  String? lastSignUpEmail;
  String? lastSignUpPassword;

  @override
  Future<UserCredential> signUp({
    required String email,
    required String password,
  }) async {
    signUpCallCount++;
    lastSignUpEmail = email;
    lastSignUpPassword = password;
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

  // ===== sendResetEmail =====
  int sendResetEmailCallCount = 0;
  String? lastResetEmail;
  Object? sendResetEmailError;

  @override
  Future<void> sendResetEmail({required String userEmail}) async {
    sendResetEmailCallCount++;
    lastResetEmail = userEmail;
    if (sendResetEmailError != null) throw sendResetEmailError!;
  }

  // ===== signOut =====
  int signOutCallCount = 0;

  @override
  Future<void> signOut() async {
    signOutCallCount++;
  }
}