import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../fakes/fake_auth_service.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:test_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:test_app/features/auth/data/repositories_impl/auth_repository_impl.dart';


void main() {
  late FakeAuthService fakeAuth;
  late AuthRepository repository;

  late UserCredential validCredential;

  setUp(() async {
    fakeAuth = FakeAuthService();
    repository = AuthRepositoryImpl(auth: fakeAuth);

    final mockAuth = MockFirebaseAuth(
      mockUser: MockUser(uid: 'uid-1', email: 'a@b.com'),
      signedIn: true,
    );
    validCredential = await mockAuth.signInWithEmailAndPassword(
      email: 'a@b.com',
      password: 'p',
    );
  });

  group('signIn', () {
    test('returns UserCredential from authService.signIn', () async {
      fakeAuth.signInResult = validCredential;

      final result = await repository.signIn(
        userEmail: 'a@b.com',
        userPassword: 'password123',
      );

      expect(result.user, isNotNull);
      expect(result.user!.uid, 'uid-1');
      expect(fakeAuth.signInCallCount, 1);
      expect(fakeAuth.lastSignInEmail, 'a@b.com');
      expect(fakeAuth.lastSignInPassword, 'password123');
    });

    test('propagates errors from authService.signIn', () async {
      fakeAuth.signInError = FirebaseAuthException(code: 'wrong-password');

      expect(
            () =>
            repository.signIn(
              userEmail: 'a@b.com',
              userPassword: 'wrong',
            ),
        throwsA(isA<FirebaseAuthException>()),
      );
    });
  });

  group('signUp', () {
    test('returns UserCredential from authService.signUp', () async {
      fakeAuth.signUpResult = validCredential;

      final result = await repository.signUp(
        userEmail: 'new@b.com',
        userPassword: 'password123',
      );

      expect(result.user, isNotNull);
      expect(fakeAuth.signUpCallCount, 1);
      expect(fakeAuth.lastSignUpEmail, 'new@b.com');
    });

    test('propagates errors from authService.signUp', () async {
      fakeAuth.signUpError =
          FirebaseAuthException(code: 'email-already-in-use');

      expect(
            () =>
            repository.signUp(
              userEmail: 'a@b.com',
              userPassword: 'p',
            ),
        throwsA(isA<FirebaseAuthException>()),
      );
    });
  });

  group('updateProfile', () {
    test('returns User from authService.updateProfile', () async {
      final mockUser = MockUser(uid: 'uid-1', email: 'new@b.com');
      fakeAuth.updateProfileResult = mockUser;

      final result = await repository.updateProfile(
        newEmail: 'new@b.com',
        currentPassword: 'old',
        newPassword: 'new',
      );

      expect(result, same(mockUser));
      expect(fakeAuth.updateProfileCallCount, 1);
      expect(fakeAuth.lastNewEmail, 'new@b.com');
    });

    test('returns null when authService.updateProfile returns null', () async {
      fakeAuth.updateProfileResult = null;

      final result = await repository.updateProfile(
        newEmail: 'new@b.com',
        currentPassword: 'old',
        newPassword: 'new',
      );

      expect(result, isNull);
    });
  });

  group('sendResetEmail', () {
    test('calls authService.sendResetEmail with the email', () async {
      await repository.sendResetEmail(userEmail: 'a@b.com');

      // بسبب عدم وجود await في Repository، قد يكون sendResetEmailCallCount == 0
      // لكن FakeAuthService.sendResetEmail سريع → يُستدعى قبل التحقق
      expect(fakeAuth.sendResetEmailCallCount, 1);
      expect(fakeAuth.lastResetEmail, 'a@b.com');
    });

    test('does not await sendResetEmail (documents bug)', () async {
      // هذا الاختبار يوثق أن sendResetEmail لا تنتظر
      // في Repository: _auth.sendResetEmail(...) بدون await

      fakeAuth.sendResetEmailError = Exception('reset failed');

      // Repository لا ينتظر → لا يرمي
      await repository.sendResetEmail(userEmail: 'a@b.com');

      // لو كان await، لرمى Exception
      // لكن بدون await، Exception يُهمل (unhandled future)
    });
  });
}