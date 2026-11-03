import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../fakes/fake_auth_repository.dart';
import '../../../../fakes/mock_session_service.dart';
import '../../../../fakes/mock_user_credential.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:test_app/features/auth/domain/use_cases/sign_in_use_case.dart';


void main() {
  late SignInUseCase useCase;
  late FakeAuthRepository fakeRepo;
  late MockSessionService mockSession;

  setUp(() {
    fakeRepo = FakeAuthRepository();
    mockSession = MockSessionService();
    useCase = SignInUseCase(
      authRepository: fakeRepo,
      sessionService: mockSession,
    );
  });

  group('signInExecute', () {
    test('passes credentials to authRepository.signIn', () async {
      final mockCredential = MockUserCredential();
      when(() => mockCredential.user).thenReturn(null);
      fakeRepo.signInResult = mockCredential;

      await useCase.signInExecute(
        userEmail: 'a@b.com',
        userPassword: 'password123',
      );

      expect(fakeRepo.signInCallCount, 1);
      expect(fakeRepo.lastSignInEmail, 'a@b.com');
      expect(fakeRepo.lastSignInPassword, 'password123');
    });

    test('calls sessionService.login with hardcoded UID (documents bug)',
            () async {
          final mockUser = MockUser();
          final mockCredential = MockUserCredential();

          when(() => mockUser.email).thenReturn('a@b.com');
          when(() => mockUser.isAnonymous).thenReturn(false);
          when(() => mockCredential.user).thenReturn(mockUser);

          fakeRepo.signInResult = mockCredential;

          when(() => mockSession.login(any())).thenAnswer((_) async {});

          await useCase.signInExecute(
            userEmail: 'a@b.com',
            userPassword: 'password123',
          );

          // ← hardcoded UID — BUG: لا يستخدم user.uid
          verify(() => mockSession.login('NCSa42aEicXZF3JSq1JHzphgQZs2')).called(1);
        });

    test('does NOT call login when user is null', () async {
      final mockCredential = MockUserCredential();
      when(() => mockCredential.user).thenReturn(null);
      fakeRepo.signInResult = mockCredential;

      await useCase.signInExecute(
        userEmail: 'a@b.com',
        userPassword: 'p',
      );

      verifyNever(() => mockSession.login(any()));
    });

    test('does NOT call login when user.email is null', () async {
      final mockUser = MockUser();
      final mockCredential = MockUserCredential();

      when(() => mockUser.email).thenReturn(null);  // ← null
      when(() => mockCredential.user).thenReturn(mockUser);

      fakeRepo.signInResult = mockCredential;

      await useCase.signInExecute(
        userEmail: 'a@b.com',
        userPassword: 'p',
      );

      verifyNever(() => mockSession.login(any()));
    });

    test('does NOT call login when user.isAnonymous is true', () async {
      final mockUser = MockUser();
      final mockCredential = MockUserCredential();

      when(() => mockUser.email).thenReturn('a@b.com');
      when(() => mockUser.isAnonymous).thenReturn(true);  // ← anonymous
      when(() => mockCredential.user).thenReturn(mockUser);

      fakeRepo.signInResult = mockCredential;

      await useCase.signInExecute(
        userEmail: 'a@b.com',
        userPassword: 'p',
      );

      verifyNever(() => mockSession.login(any()));
    });

    test('propagates errors from authRepository.signIn', () async {
      fakeRepo.signInError = FirebaseAuthException(code: 'wrong-password');

      expect(
            () => useCase.signInExecute(
          userEmail: 'a@b.com',
          userPassword: 'wrong',
        ),
        throwsA(isA<FirebaseAuthException>()),
      );

      verifyNever(() => mockSession.login(any()));
    });
  });
}