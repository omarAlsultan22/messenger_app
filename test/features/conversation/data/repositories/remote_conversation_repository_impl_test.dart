import 'package:flutter_test/flutter_test.dart';
import '../../../../fakes/fake_conversation_data_source.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:test_app/features/conversation/data/models/conversation_model.dart';
import 'package:test_app/features/conversation/domain/repositories/remote_conversation_repository.dart';
import 'package:test_app/features/conversation/data/repositories_impl/remote_conversation_repository_impl.dart';


void main() {
  late FakeConversationDataSource fakeDataSource;
  late RemoteConversationRepository repository;
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() {
    fakeDataSource = FakeConversationDataSource();
    fakeFirestore = FakeFirebaseFirestore();
    repository = RemoteConversationRepositoryImpl(dataSource: fakeDataSource);
  });

  group('updateUnreadMessages', () {
    test('delegates to dataSource.updateUnreadMessages', () async {
      await repository.updateUnreadMessages(docId: 'chat-1');

      expect(fakeDataSource.updateUnreadMessagesCallCount, 1);
      expect(fakeDataSource.lastUnreadDocId, 'chat-1');
    });
  });

  group('getConversationsStream', () {
    test('delegates to dataSource.getConversationsStream with docId only',
            () async {
          fakeDataSource.conversationsStream = const Stream.empty();

          repository.getConversationsStream(docId: 'chat-1');

          expect(fakeDataSource.getConversationsStreamCallCount, 1);
          expect(fakeDataSource.lastConversationsDocId, 'chat-1');
        });

    test('does NOT pass startAfterDocument/endBeforeDocument/limit (bug)',
            () async {
          fakeDataSource.conversationsStream = const Stream.empty();
          final doc = await fakeFirestore.collection('x').doc('d1').get();

          repository.getConversationsStream(
            docId: 'chat-1',
            startAfterDocument: doc,
            endBeforeDocument: doc,
            limit: 10,
          );

          // نثبت أن dataSource استقبل docId فقط
          expect(fakeDataSource.lastConversationsDocId, 'chat-1');
          // لا يمكن التحقق من startAfter/endBefore/limit لأنها لا تُمرر
          // هذا يوثق bug — المعاملات تُتجاهل
        });
  });

  group('getOldMessagesQuery', () {
    test('delegates to dataSource.getOldMessagesQuery with docId only',
            () async {
          fakeDataSource.oldMessagesResult = await fakeFirestore
              .collection('messages')
              .doc('chat-1')
              .collection('conversations')
              .get();

          await repository.getOldMessagesQuery(docId: 'chat-1');

          expect(fakeDataSource.getOldMessagesQueryCallCount, 1);
          expect(fakeDataSource.lastOldMessagesDocId, 'chat-1');
        });
  });

  group('updateTypingStatus', () {
    test('delegates to dataSource.updateTypingStatus', () async {
      await repository.updateTypingStatus(userId: 'user-1', isTyping: true);

      expect(fakeDataSource.updateTypingStatusCallCount, 1);
      expect(fakeDataSource.lastTypingUserId, 'user-1');
      expect(fakeDataSource.lastIsTyping, true);
    });
  });

  group('clearConversations', () {
    test('delegates to dataSource.clearConversations', () async {
      await repository.clearConversations(docId: 'chat-1');

      expect(fakeDataSource.clearConversationsCallCount, 1);
      expect(fakeDataSource.lastClearDocId, 'chat-1');
    });
  });

  group('deleteMessages', () {
    test('delegates to dataSource.deleteMessages', () async {
      await repository.deleteMessages(
        docId: 'chat-1',
        messagesIds: ['m1', 'm2'],
      );

      expect(fakeDataSource.deleteMessagesCallCount, 1);
      expect(fakeDataSource.lastDeleteDocId, 'chat-1');
      expect(fakeDataSource.lastMessagesIds, ['m1', 'm2']);
    });
  });

  group('sendMessage', () {
    test('delegates to dataSource.sendMessage', () async {
      final conversation = ConversationModel(
        text: 'Hello',
        senderId: 'user-1',
      );

      await repository.sendMessage(
        docId: 'chat-1',
        conversation: conversation,
      );

      expect(fakeDataSource.sendMessageCallCount, 1);
      expect(fakeDataSource.lastSendDocId, 'chat-1');
      expect(fakeDataSource.lastConversation, conversation);
    });
  });

  group('getMessageDocumentReference', () {
    test('delegates to dataSource.getMessageDocumentReference', () {
      final ref = fakeFirestore
          .collection('messages')
          .doc('chat-1')
          .collection('conversations')
          .doc('m1');
      fakeDataSource.messageDocumentReference = ref;

      final result = repository.getMessageDocumentReference(
        docId: 'chat-1',
        messageId: 'm1',
      );

      expect(result, same(ref));
      expect(fakeDataSource.lastMessageRefDocId, 'chat-1');
      expect(fakeDataSource.lastMessageRefMessageId, 'm1');
    });
  });
}