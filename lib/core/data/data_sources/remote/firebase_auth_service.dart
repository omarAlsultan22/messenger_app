import '../../../constants/app_durations.dart';
import 'package:firebase_auth/firebase_auth.dart';


class FirebaseAuthService {
  static const _duration = AppDurations.seconds;
  static final _firebaseAuth = FirebaseAuth.instance;

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password
    ).timeout(_duration);
  }

  Future<UserCredential> signUp({
    required String email,
    required String password
  }) async {
    return await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password
    ).timeout(_duration);
  }

  Future<User?> updateProfile({
    required String newEmail,
    required String currentPassword,
    required String newPassword
  }) async {
    final user = _firebaseAuth.currentUser;
    return user;
  }

  Future<void> sendResetEmail({
    required String userEmail,
  }) async {
    await _firebaseAuth.sendPasswordResetEmail(email: userEmail);
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut().timeout(_duration);
  }
}