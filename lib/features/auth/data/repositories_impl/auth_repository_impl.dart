import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/domain/data_sources/auth_service.dart';


class AuthRepositoryImpl implements AuthRepository {
  final AuthService _auth;

  AuthRepositoryImpl({required AuthService auth}) : _auth = auth;

  @override
  Future<UserCredential> signIn({
    required String userEmail,
    required String userPassword
  }) async {
      return await _auth.signIn(
        email: userEmail,
        password: userPassword,
      ).then((value) {
        return value;
      });
    }

  @override
  Future<UserCredential> signUp({
    required String userEmail,
    required String userPassword
  }) async {
      return await _auth
          .signUp(
          email: userEmail,
          password: userPassword
      ).then((value) {
        return value;
      });
  }

  @override
  Future<User?> updateProfile({
    required String newEmail,
    required String currentPassword,
    required String newPassword
  }) async {
    final user = await _auth.updateProfile(
        newEmail: newEmail,
        currentPassword: currentPassword,
        newPassword: newPassword);
    return user;
  }

  @override
  Future<void> sendResetEmail({required String userEmail}) async {
    _auth.sendResetEmail(userEmail: userEmail);
  }
}