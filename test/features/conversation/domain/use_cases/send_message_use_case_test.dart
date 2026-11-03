import 'package:flutter_test/flutter_test.dart';
import '../../../../fakes/fake_remote_conversation_repository.dart';
import 'package:test_app/features/conversation/data/models/conversation_model.dart';
import 'package:test_app/features/conversation/domain/use_cases/send_message_use_case.dart';


void main() {
  late FakeRemoteConversationRepository fakeRepo;
  late SendMessageUseCase useCase;

  final conversation = ConversationModel(
    messageId: 'm1',
    text: 'Hello',
    senderId: 'user-1',
  );

  setUp(() {
    fakeRepo = FakeRemoteConversationRepository();
    useCase = SendMessageUseCase(repository: fakeRepo);
  });

  group('execute', () {
    test('calls repository.sendMessage with docId and conversation', () async {
      await useCase.execute(
        docId: 'chat-1',
        conversation: conversation,
        organizeMessages: (_) {},
      );

      expect(fakeRepo.sendMessageCallCount, 1);
      expect(fakeRepo.lastSendDocId, 'chat-1');
      expect(fakeRepo.lastSendConversation, same(conversation));
    });

    test('calls organizeMessages with [conversation] after sendMessage',
            () async {
          List<ConversationModel>? capturedMessages;

          await useCase.execute(
            docId: 'chat-1',
            conversation: conversation,
            organizeMessages: (messages) {
              capturedMessages = messages;
            },
          );

          expect(capturedMessages, isNotNull);
          expect(capturedMessages!.length, 1);
          expect(capturedMessages!.first, same(conversation));
        });

    test('does not call organizeMessages when sendMessage throws', () async {
      fakeRepo.sendMessageError = Exception('send failed');
      var organizeCalled = false;

      expect(
            () => useCase.execute(
          docId: 'chat-1',
          conversation: conversation,
          organizeMessages: (_) {
            organizeCalled = true;
          },
        ),
        throwsA(isA<Exception>()),
      );

      // organizeMessages لم يُستدعَ
      expect(organizeCalled, false);
    });
  });
}