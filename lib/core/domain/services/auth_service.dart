import 'package:firebase_auth/firebase_auth.dart';


abstract class AuthService {
  Future<UserCredential> signIn({
    required String email,
    required String password,
  });

  Future<UserCredential> signUp({
    required String email,
    required String password
  });

  Future<User?> updateProfile({
    required String newEmail,
    required String currentPassword,
    required String newPassword
  });

  Future<void> sendResetEmail({
    required String userEmail,
  });

  Future<void> signOut();
}