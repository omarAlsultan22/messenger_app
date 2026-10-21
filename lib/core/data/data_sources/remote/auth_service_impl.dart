import '../../../constants/app_durations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../domain/data_sources/auth_service.dart';


class AuthServiceImpl implements AuthService{
  static const _duration = AppDurations.seconds;
  static final _firebaseAuth = FirebaseAuth.instance;

  @override
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password
    ).timeout(_duration);
  }

  @override
  Future<UserCredential> signUp({
    required String email,
    required String password
  }) async {
    return await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password
    ).timeout(_duration);
  }

  @override
  Future<User?> updateProfile({
    required String newEmail,
    required String currentPassword,
    required String newPassword
  }) async {
    final user = _firebaseAuth.currentUser;
    return user;
  }

  @override
  Future<void> sendResetEmail({
    required String userEmail,
  }) async {
    await _firebaseAuth.sendPasswordResetEmail(email: userEmail);
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut().timeout(_duration);
  }
}