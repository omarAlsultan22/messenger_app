import 'package:flutter_test/flutter_test.dart';
import '../../../../fixtures/message_groups.dart';
import '../../../../fakes/fake_remote_conversation_repository.dart';
import 'package:test_app/features/conversation/data/models/message_group.dart';
import 'package:test_app/features/conversation/domain/use_cases/delete_messages_use_case.dart';


void main() {
  late FakeRemoteConversationRepository fakeRepo;
  late DeleteMessagesUseCase useCase;

  setUp(() {
    fakeRepo = FakeRemoteConversationRepository();
    useCase = DeleteMessagesUseCase(repository: fakeRepo);
  });

  group('execute', () {
    test('removes deleted messages from groups and calls repository',
            () async {
          final group = MessageGroup(
              messages: [message1, message2],
              sortDate: DateTime(2024, 5, 1),
              date: DateTime(2024, 5, 1).toString()
          );
          final list = [group];

          await useCase.execute(
            docId: 'chat-1',
            messagesIds: ['m1'],
            conversationList: list,
          );

          // m1 أُزيل، m2 بقي
          expect(group.messages.length, 1);
          expect(group.messages.first.messageId, 'm2');

          // repository استُدعي
          expect(fakeRepo.deleteMessagesCallCount, 1);
          expect(fakeRepo.lastDeleteDocId, 'chat-1');
          expect(fakeRepo.lastMessagesIds, ['m1']);
        });

    test('removes empty groups from the list', () async {
      final group1 = MessageGroup(
          messages: [message1],
          sortDate: DateTime(2024, 5, 1),
          date: DateTime(2024, 5, 1).toString()
      );
      final group2 = MessageGroup(
          messages: [message2],
          sortDate: DateTime(2024, 5, 2),
          date: DateTime(2024, 5, 2).toString()
      );
      final list = [group1, group2];

      await useCase.execute(
        docId: 'chat-1',
        messagesIds: ['m1'], // يحذف كل رسائل group1
        conversationList: list,
      );

      // group1 فارغة → أُزيلت
      expect(list.length, 1);
      expect(list.first, same(group2));
    });

    test('keeps groups that still have messages', () async {
      final group = MessageGroup(
          messages: [message1, message2],
          sortDate: DateTime(2024, 5, 1),
          date: DateTime(2024, 5, 1).toString()
      );
      final list = [group];

      await useCase.execute(
        docId: 'chat-1',
        messagesIds: ['m1'],
        conversationList: list,
      );

      // group ما زالت موجودة (لأن m2 بقي)
      expect(list.length, 1);
      expect(list.first.messages.length, 1);
    });

    test('does nothing to groups that have no matching messages', () async {
      final group = MessageGroup(
          messages: [message1],
          sortDate: DateTime(2024, 5, 1),
          date: DateTime(2024, 5, 1).toString()
      );
      final list = [group];

      await useCase.execute(
        docId: 'chat-1',
        messagesIds: ['m99'], // لا يوجد
        conversationList: list,
      );

      expect(group.messages.length, 1);
      expect(list.length, 1);
    });

    test('handles empty conversation list', () async {
      final list = <MessageGroup>[];

      await useCase.execute(
        docId: 'chat-1',
        messagesIds: ['m1'],
        conversationList: list,
      );

      expect(list, isEmpty);
      expect(fakeRepo.deleteMessagesCallCount, 1);
    });

    test('handles empty messagesIds', () async {
      final group = MessageGroup(
          messages: [message1],
          sortDate: DateTime(2024, 5, 1),
          date: DateTime(2024, 5, 1).toString()
      );
      final list = [group];

      await useCase.execute(
        docId: 'chat-1',
        messagesIds: [],
        conversationList: list,
      );

      // لا شيء يُحذف
      expect(group.messages.length, 1);
      expect(list.length, 1);
      expect(fakeRepo.deleteMessagesCallCount, 1);
      expect(fakeRepo.lastMessagesIds, isEmpty);
    });

    test('propagates errors from repository', () async {
      final group = MessageGroup(
          messages: [message1],
          sortDate: DateTime(2024, 5, 1),
          date: DateTime(2024, 5, 1).toString()
      );
      final list = [group];
      fakeRepo.deleteMessagesError = Exception('delete failed');

      expect(
            () =>
            useCase.execute(
              docId: 'chat-1',
              messagesIds: ['m1'],
              conversationList: list,
            ),
        throwsA(isA<Exception>()),
      );
    });
  });
}