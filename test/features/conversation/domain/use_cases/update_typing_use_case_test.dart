import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import '../../../../fakes/fake_remote_conversation_repository.dart';
import 'package:test_app/features/conversation/domain/use_cases/update_typing_use_case.dart';


void main() {
  late FakeRemoteConversationRepository fakeRepo;
  late UpdateTypingUseCase useCase;

  group('execute - user signed in', () {
    late MockFirebaseAuth mockAuth;

    setUp(() {
      mockAuth = MockFirebaseAuth(
        mockUser: MockUser(uid: 'uid-123', email: 'a@b.com'),
        signedIn: true,
      );
      fakeRepo = FakeRemoteConversationRepository();
      useCase = UpdateTypingUseCase(
        repository: fakeRepo,
        auth: mockAuth,
      );
    });

    test('calls updateTypingStatus with currentUser.uid and isTyping',
            () async {
          await useCase.execute(true);

          expect(fakeRepo.updateTypingStatusCallCount, 1);
          expect(fakeRepo.lastTypingUserId, 'uid-123');
          expect(fakeRepo.lastIsTyping, true);
        });

    test('passes isTyping false correctly', () async {
      await useCase.execute(false);

      expect(fakeRepo.lastIsTyping, false);
    });

    test('propagates errors from repository', () async {
      fakeRepo.updateTypingStatusError = Exception('update failed');

      expect(
            () => useCase.execute(true),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('execute - user not signed in', () {
    late MockFirebaseAuth mockAuth;

    setUp(() {
      mockAuth = MockFirebaseAuth(signedIn: false);
      fakeRepo = FakeRemoteConversationRepository();
      useCase = UpdateTypingUseCase(
        repository: fakeRepo,
        auth: mockAuth,
      );
    });

    test('does nothing when currentUser is null', () async {
      await useCase.execute(true);

      // updateTypingStatus لم يُستدعَ
      expect(fakeRepo.updateTypingStatusCallCount, 0);
    });

    test('does nothing when currentUser is null and isTyping is false',
            () async {
          await useCase.execute(false);

          expect(fakeRepo.updateTypingStatusCallCount, 0);
        });
  });
}