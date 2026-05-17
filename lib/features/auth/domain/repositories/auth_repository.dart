import 'package:firebase_auth/firebase_auth.dart';


abstract class AuthRepository {
  Future<UserCredential> signIn({
    required String userEmail,
    required String userPassword,
  });

  Future<UserCredential> signUp({
    required String userEmail,
    required String userPassword,
  });

  Future<User?> updateProfile({
    required String newEmail,
    required String currentPassword,
    required String newPassword
  });

  Future<void> sendResetEmail({
    required String userEmail,
  });
}