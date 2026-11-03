import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:test_app/features/conversation/data/models/conversation_model.dart';
import 'package:test_app/features/conversation/domain/data_sources/conversation_data_source.dart';
import 'package:test_app/features/conversation/data/data_sources/remote/conversation_data_source_impl.dart';


void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late ConversationDataSource dataSource;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    dataSource = ConversationDataSourceImpl(firestore: fakeFirestore);
  });

  group('updateUnreadMessages', () {
    test('updates all unread messages to read', () async {
      await fakeFirestore
          .collection('messages')
          .doc('chat-1')
          .collection('conversations')
          .doc('m1')
          .set({'unreadMessage': true, 'text': 'A'});
      await fakeFirestore
          .collection('messages')
          .doc('chat-1')
          .collection('conversations')
          .doc('m2')
          .set({'unreadMessage': true, 'text': 'B'});
      await fakeFirestore
          .collection('messages')
          .doc('chat-1')
          .collection('conversations')
          .doc('m3')
          .set({'unreadMessage': false, 'text': 'C'});

      await dataSource.updateUnreadMessages(docId: 'chat-1');

      final docs = await fakeFirestore
          .collection('messages')
          .doc('chat-1')
          .collection('conversations')
          .get();

      for (final doc in docs.docs) {
        expect(doc.data()['unreadMessage'], false);
      }
    });

    test('does nothing when there are no unread messages', () async {
      await fakeFirestore
          .collection('messages')
          .doc('chat-1')
          .collection('conversations')
          .doc('m1')
          .set({'unreadMessage': false});

      await dataSource.updateUnreadMessages(docId: 'chat-1');

      final doc = await fakeFirestore
          .collection('messages')
          .doc('chat-1')
          .collection('conversations')
          .doc('m1')
          .get();
      expect(doc.data()?['unreadMessage'], false);
    });
  });

  group('getConversationsStream', () {
    test('returns conversations ordered by dateTime descending', () async {
      await fakeFirestore
          .collection('messages')
          .doc('chat-1')
          .collection('conversations')
          .doc('m1')
          .set({'text': 'Old', 'dateTime': 1000});
      await fakeFirestore
          .collection('messages')
          .doc('chat-1')
          .collection('conversations')
          .doc('m2')
          .set({'text': 'New', 'dateTime': 2000});

      final stream = dataSource.getConversationsStream(docId: 'chat-1');
      final snapshot = await stream.first;

      expect(snapshot.docs.length, 2);
      expect(snapshot.docs.first.data()??['text'], 'New');
    });

    test('applies limit when provided', () async {
      for (int i = 0; i < 5; i++) {
        await fakeFirestore
            .collection('messages')
            .doc('chat-1')
            .collection('conversations')
            .doc('m$i')
            .set({'text': 'M$i', 'dateTime': i * 1000});
      }

      final stream = dataSource.getConversationsStream(
        docId: 'chat-1',
        limit: 2,
      );
      final snapshot = await stream.first;

      expect(snapshot.docs.length, 2);
    });

    test('applies startAfterDocument when provided', () async {
      await fakeFirestore
          .collection('messages')
          .doc('chat-1')
          .collection('conversations')
          .doc('m1')
          .set({'text': 'A', 'dateTime': 1000});
      await fakeFirestore
          .collection('messages')
          .doc('chat-1')
          .collection('conversations')
          .doc('m2')
          .set({'text': 'B', 'dateTime': 2000});
      await fakeFirestore
          .collection('messages')
          .doc('chat-1')
          .collection('conversations')
          .doc('m3')
          .set({'text': 'C', 'dateTime': 3000});

      final firstDoc = await fakeFirestore
          .collection('messages')
          .doc('chat-1')
          .collection('conversations')
          .doc('m3')
          .get();

      final stream = dataSource.getConversationsStream(
        docId: 'chat-1',
        startAfterDocument: firstDoc,
      );
      final snapshot = await stream.first;

      // بعد m3 (dateTime 3000) — لا شيء
      expect(snapshot.docs, isEmpty);
    });
  });

  group('getOldMessagesQuery', () {
    test('returns messages with default limit 15', () async {
      for (int i = 0; i < 20; i++) {
        await fakeFirestore
            .collection('messages')
            .doc('chat-1')
            .collection('conversations')
            .doc('m$i')
            .set({'text': 'M$i', 'dateTime': i * 1000});
      }

      final result = await dataSource.getOldMessagesQuery(docId: 'chat-1');

      expect(result.docs.length, 15);
    });

    test('applies lastDocument when provided', () async {
      await fakeFirestore
          .collection('messages')
          .doc('chat-1')
          .collection('conversations')
          .doc('m1')
          .set({'text': 'A', 'dateTime': 1000});
      await fakeFirestore
          .collection('messages')
          .doc('chat-1')
          .collection('conversations')
          .doc('m2')
          .set({'text': 'B', 'dateTime': 2000});

      final lastDoc = await fakeFirestore
          .collection('messages')
          .doc('chat-1')
          .collection('conversations')
          .doc('m2')
          .get();

      final result = await dataSource.getOldMessagesQuery(
        docId: 'chat-1',
        lastDocument: lastDoc,
      );

      // بعد m2 (dateTime 2000) — لا شيء
      expect(result.docs, isEmpty);
    });
  });

  group('updateTypingStatus', () {
    test('updates isTyping on the accounts document', () async {
      await fakeFirestore
          .collection('accounts')
          .doc('user-1')
          .set({'isTyping': false});

      await dataSource.updateTypingStatus(userId: 'user-1', isTyping: true);

      final doc =
      await fakeFirestore.collection('accounts').doc('user-1').get();
      expect(doc.data()?['isTyping'], true);
    });
  });

  group('clearConversations', () {
    test('deletes the messages document', () async {
      await fakeFirestore
          .collection('messages')
          .doc('chat-1')
          .set({'participants': ['a', 'b']});

      await dataSource.clearConversations(docId: 'chat-1');

      final doc = await fakeFirestore.collection('messages').doc('chat-1').get();
      expect(doc.exists, false);
    });
  });

  group('deleteMessages', () {
    test('deletes multiple messages in a batch', () async {
      await fakeFirestore
          .collection('messages')
          .doc('chat-1')
          .collection('conversations')
          .doc('m1')
          .set({'text': 'A'});
      await fakeFirestore
          .collection('messages')
          .doc('chat-1')
          .collection('conversations')
          .doc('m2')
          .set({'text': 'B'});
      await fakeFirestore
          .collection('messages')
          .doc('chat-1')
          .collection('conversations')
          .doc('m3')
          .set({'text': 'C'});

      await dataSource.deleteMessages(
        docId: 'chat-1',
        messagesIds: ['m1', 'm3'],
      );

      final docs = await fakeFirestore
          .collection('messages')
          .doc('chat-1')
          .collection('conversations')
          .get();

      expect(docs.docs.length, 1);
      expect(docs.docs.first.id, 'm2');
    });

    test('does nothing when messagesIds is empty', () async {
      await fakeFirestore
          .collection('messages')
          .doc('chat-1')
          .collection('conversations')
          .doc('m1')
          .set({'text': 'A'});

      await dataSource.deleteMessages(docId: 'chat-1', messagesIds: []);

      final docs = await fakeFirestore
          .collection('messages')
          .doc('chat-1')
          .collection('conversations')
          .get();
      expect(docs.docs.length, 1);
    });
  });

  group('sendMessage', () {
    test('adds a message and sets messageId', () async {
      final conversation = ConversationModel(
        text: 'Hello',
        senderId: 'user-1',
        // ... الحقول المطلوبة
      );

      await dataSource.sendMessage(docId: 'chat-1', conversation: conversation);

      final docs = await fakeFirestore
          .collection('messages')
          .doc('chat-1')
          .collection('conversations')
          .get();

      expect(docs.docs.length, 1);
      expect(docs.docs.first.data()['text'], 'Hello');
      expect(conversation.messageId, isNotNull);
      expect(conversation.messageId, docs.docs.first.id);
    });
  });

  group('getMessageDocumentReference', () {
    test('returns the correct DocumentReference', () {
      final ref = dataSource.getMessageDocumentReference(
        docId: 'chat-1',
        messageId: 'm1',
      );

      expect(ref.path, 'messages/chat-1/conversations/m1');
    });
  });
}