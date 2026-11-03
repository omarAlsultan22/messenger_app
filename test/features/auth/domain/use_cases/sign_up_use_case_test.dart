import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../../fakes/fake_auth_repository.dart';
import '../../../../fakes/mock_user_credential.dart';
import '../../../../fakes/fake_sign_up_repository.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:test_app/features/auth/domain/use_cases/sign_up_use_case.dart';


void main() {
  late FakeAuthRepository fakeAuth;
  late FakeSignUpRepository fakeSignUp;
  late SignUpUseCase useCase;

  setUp(() {
    fakeAuth = FakeAuthRepository();
    fakeSignUp = FakeSignUpRepository();
    useCase = SignUpUseCase(
      authRepository: fakeAuth,
      signUpRepository: fakeSignUp,
    );
  });

  group('signUpExecute', () {
    test('passes credentials to authRepository.signUp', () async {
      final mockCredential = MockUserCredential();
      when(() => mockCredential.user).thenReturn(null);
      fakeAuth.signUpResult = mockCredential;

      await useCase.signUpExecute(
        firstName: 'Ali',
        lastName: 'Ahmed',
        userEmail: 'a@b.com',
        userPassword: 'password123',
      );

      expect(fakeAuth.signUpCallCount, 1);
      expect(fakeAuth.lastSignUpEmail, 'a@b.com');
      expect(fakeAuth.lastSignUpPassword, 'password123');
    });

    test('calls createUserInfo with correct UserModel on success', () async {
      final mockUser = MockUser();
      final mockCredential = MockUserCredential();

      when(() => mockUser.uid).thenReturn('uid-123');
      when(() => mockUser.email).thenReturn('a@b.com');
      when(() => mockUser.isAnonymous).thenReturn(false);
      when(() => mockCredential.user).thenReturn(mockUser);

      fakeAuth.signUpResult = mockCredential;

      await useCase.signUpExecute(
        firstName: 'Ali',
        lastName: 'Ahmed',
        userEmail: 'a@b.com',
        userPassword: 'password123',
      );

      expect(fakeSignUp.createUserInfoCallCount, 1);
      final userModel = fakeSignUp.lastUserModel!;
      expect(userModel.userId, 'uid-123');
      expect(userModel.firstName, 'Ali');
      expect(userModel.lastName, 'Ahmed');
      expect(userModel.fullName, 'AliAhmed'); // ← fullName
    });

    test('does NOT call createUserInfo when user is null', () async {
      final mockCredential = MockUserCredential();
      when(() => mockCredential.user).thenReturn(null);
      fakeAuth.signUpResult = mockCredential;

      await useCase.signUpExecute(
        firstName: 'Ali',
        lastName: 'Ahmed',
        userEmail: 'a@b.com',
        userPassword: 'p',
      );

      expect(fakeSignUp.createUserInfoCallCount, 0);
    });

    test('does NOT call createUserInfo when user.email is null', () async {
      final mockUser = MockUser();
      final mockCredential = MockUserCredential();

      when(() => mockUser.email).thenReturn(null); // ← null
      when(() => mockCredential.user).thenReturn(mockUser);

      fakeAuth.signUpResult = mockCredential;

      await useCase.signUpExecute(
        firstName: 'Ali',
        lastName: 'Ahmed',
        userEmail: 'a@b.com',
        userPassword: 'p',
      );

      expect(fakeSignUp.createUserInfoCallCount, 0);
    });

    test('does NOT call createUserInfo when user.isAnonymous is true',
            () async {
          final mockUser = MockUser();
          final mockCredential = MockUserCredential();

          when(() => mockUser.email).thenReturn('a@b.com');
          when(() => mockUser.isAnonymous).thenReturn(true);
          when(() => mockCredential.user).thenReturn(mockUser);

          fakeAuth.signUpResult = mockCredential;

          await useCase.signUpExecute(
            firstName: 'Ali',
            lastName: 'Ahmed',
            userEmail: 'a@b.com',
            userPassword: 'p',
          );

          expect(fakeSignUp.createUserInfoCallCount, 0);
        });

    test('propagates errors from createUserInfo', () async {
      final mockUser = MockUser();
      final mockCredential = MockUserCredential();

      when(() => mockUser.uid).thenReturn('uid-123');
      when(() => mockUser.email).thenReturn('a@b.com');
      when(() => mockUser.isAnonymous).thenReturn(false);
      when(() => mockCredential.user).thenReturn(mockUser);

      fakeAuth.signUpResult = mockCredential;
      fakeSignUp.createUserInfoError = Exception('save failed');

      expect(
            () =>
            useCase.signUpExecute(
              firstName: 'Ali',
              lastName: 'Ahmed',
              userEmail: 'a@b.com',
              userPassword: 'p',
            ),
        throwsA(isA<Exception>()),
      );
    });
  });
}