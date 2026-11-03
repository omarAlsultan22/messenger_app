import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../fakes/fake_auth_repository.dart';
import '../../../../fakes/mock_user_credential.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:test_app/features/auth/domain/use_cases/change_email_and_password_use_case.dart';


class MockAuthCredential extends Mock implements AuthCredential {}


void main() {
  late FakeAuthRepository fakeRepo;
  late ChangeEmailAndPasswordUseCase useCase;

  setUp(() {
    fakeRepo = FakeAuthRepository();
    useCase = ChangeEmailAndPasswordUseCase(authRepository: fakeRepo);
  });

  setUpAll(() {
    registerFallbackValue(MockAuthCredential());
    registerFallbackValue(MockUserCredential());
  });

  group('updateProfileExecute', () {
    test('does nothing when updateProfile returns null', () async {
      fakeRepo.updateProfileResult = null;

      await useCase.updateProfileExecute(
        newEmail: 'new@b.com',
        newPassword: 'newPass',
        currentPassword: 'currentPass',
      );

      expect(fakeRepo.updateProfileCallCount, 1);
      // لا استدعاءات على user (لأنه null)
    });

    test('passes parameters to updateProfile', () async {
      fakeRepo.updateProfileResult = null;

      await useCase.updateProfileExecute(
        newEmail: 'new@b.com',
        newPassword: 'newPass',
        currentPassword: 'currentPass',
      );

      expect(fakeRepo.lastNewEmail, 'new@b.com');
      expect(fakeRepo.lastCurrentPassword, 'currentPass');
      expect(fakeRepo.lastNewPassword, 'newPass');
    });

    test('reauthenticates and verifies email when user is not null', () async {
      final mockUser = MockUser();
      final mockCredential = MockUserCredential();

      when(() => mockUser.email).thenReturn('old@b.com');
      when(() => mockUser.reauthenticateWithCredential(any()))
          .thenAnswer((_) async => mockCredential);
      when(() => mockUser.verifyBeforeUpdateEmail(any()))
          .thenAnswer((_) async {});
      when(() => mockUser.updatePassword(any())).thenAnswer((_) async {});

      fakeRepo.updateProfileResult = mockUser;

      await useCase.updateProfileExecute(
        newEmail: 'new@b.com',
        newPassword: 'newPass',
        currentPassword: 'currentPass',
      );

      verify(() => mockUser.reauthenticateWithCredential(any())).called(1);
      verify(() => mockUser.verifyBeforeUpdateEmail('new@b.com')).called(1);
    });

    test('throws when user.email is null (user.email!)', () async {
      final mockUser = MockUser();
      when(() => mockUser.email).thenReturn(null);  // ← null

      fakeRepo.updateProfileResult = mockUser;

      expect(
            () => useCase.updateProfileExecute(
          newEmail: 'new@b.com',
          newPassword: 'newPass',
          currentPassword: 'currentPass',
        ),
        throwsA(isA<TypeError>()),  // ← user.email! على null
      );
    });

    test('propagates errors from updateProfile', () async {
      fakeRepo.updateProfileError = Exception('update failed');

      expect(
            () => useCase.updateProfileExecute(
          newEmail: 'new@b.com',
          newPassword: 'newPass',
          currentPassword: 'currentPass',
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('propagates errors from reauthenticateWithCredential', () async {
      final mockUser = MockUser();
      when(() => mockUser.email).thenReturn('old@b.com');
      when(() => mockUser.reauthenticateWithCredential(any()))
          .thenThrow(Exception('reauth failed'));

      fakeRepo.updateProfileResult = mockUser;

      expect(
            () => useCase.updateProfileExecute(
          newEmail: 'new@b.com',
          newPassword: 'newPass',
          currentPassword: 'currentPass',
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}