import '../../../../core/data/data_sources/remote/firebase_auth_service.dart';
import '../../domain/repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';


class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuthService _auth;

  FirebaseAuthRepository({required FirebaseAuthService auth}) : _auth = auth;

  @override
  Future<UserCredential> signIn({
    required String userEmail,
    required String userPassword
  }) async {
    try {
      return await _auth.signIn(
        email: userEmail,
        password: userPassword,
      ).then((value) {
        return value;
      });
    }
    catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserCredential> signUp({
    required String userEmail,
    required String userPassword
  }) async {
    try {
      return await _auth
          .signUp(
          email: userEmail,
          password: userPassword
      ).then((value) {
        return value;
      });
    }
    catch (e) {
      rethrow;
    }
  }

  @override
  Future<User?> updateProfile({
    required String newEmail,
    required String currentPassword,
    required String newPassword
  }) async {
    try {
      final user = _auth.updateProfile(
          newEmail: newEmail,
          currentPassword: currentPassword,
          newPassword: newPassword);
      return user;
    }
    catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> sendResetEmail({required String userEmail}) async {
    _auth.sendResetEmail(userEmail: userEmail);
  }
}