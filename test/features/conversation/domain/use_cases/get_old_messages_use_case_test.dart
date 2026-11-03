import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import '../../../../fakes/fake_remote_conversation_repository.dart';
import 'package:test_app/features/conversation/data/models/data_model.dart';
import 'package:test_app/features/conversation/domain/use_cases/get_old_messages_use_case.dart';


void main() {
  late GetOldMessagesUseCase useCase;
  late FakeFirebaseFirestore fakeFirestore;
  late FakeRemoteConversationRepository fakeRepo;

  setUp(() {
    fakeRepo = FakeRemoteConversationRepository();
    fakeFirestore = FakeFirebaseFirestore();
    useCase = GetOldMessagesUseCase(repository: fakeRepo);
  });

  group('execute', () {
    test('emits empty DataModel when snapshot is empty', () async {
      final emptySnapshot = await fakeFirestore
          .collection('messages')
          .doc('chat-1')
          .collection('conversations')
          .get();
      fakeRepo.oldMessagesResult = emptySnapshot;

      final result = await useCase.execute(docId: 'chat-1');

      expect(result, isA<DataModel>());
      expect(result.conversationList, isEmpty);
      expect(result.lastDocument, isNull);
    });

    test('passes docId, lastDocument, and limit 15 to repository', () async {
      final emptySnapshot = await fakeFirestore
          .collection('messages')
          .doc('chat-1')
          .collection('conversations')
          .get();
      fakeRepo.oldMessagesResult = emptySnapshot;

      final lastDoc = await fakeFirestore
          .collection('messages')
          .doc('chat-1')
          .collection('conversations')
          .doc('m1')
          .get();

      await useCase.execute(docId: 'chat-1', lastDocument: lastDoc);

      expect(fakeRepo.getOldMessagesQueryCallCount, 1);
      expect(fakeRepo.lastOldMessagesDocId, 'chat-1');
      expect(fakeRepo.lastOldMessagesLastDocument, same(lastDoc));
      expect(fakeRepo.lastOldMessagesLimit, 15);
    });

    test('reverses the order of messages', () async {
      await fakeFirestore
          .collection('messages')
          .doc('chat-1')
          .collection('conversations')
          .doc('m1')
          .set({
        'senderId': 'friend-1',
        'text': 'First',
        'dateTime': Timestamp.fromDate(DateTime(2024, 5, 1)),
      });
      await fakeFirestore
          .collection('messages')
          .doc('chat-1')
          .collection('conversations')
          .doc('m2')
          .set({
        'senderId': 'friend-1',
        'text': 'Second',
        'dateTime': Timestamp.fromDate(DateTime(2024, 5, 1)),
      });

      final snapshot = await fakeFirestore
          .collection('messages')
          .doc('chat-1')
          .collection('conversations')
          .get();
      fakeRepo.oldMessagesResult = snapshot;

      final result = await useCase.execute(docId: 'chat-1');

      final messages = result.conversationList.first.messages;
      expect(messages.first.text, 'Second');
      expect(messages.last.text, 'First');
    });

    test('groups messages by date header', () async {
      await fakeFirestore
          .collection('messages')
          .doc('chat-1')
          .collection('conversations')
          .doc('m1')
          .set({
        'senderId': 'friend-1',
        'text': 'Day 1',
        'dateTime': Timestamp.fromDate(DateTime(2024, 5, 1)),
      });
      await fakeFirestore
          .collection('messages')
          .doc('chat-1')
          .collection('conversations')
          .doc('m2')
          .set({
        'senderId': 'friend-1',
        'text': 'Day 2',
        'dateTime': Timestamp.fromDate(DateTime(2024, 5, 2)),
      });

      final snapshot = await fakeFirestore
          .collection('messages')
          .doc('chat-1')
          .collection('conversations')
          .get();
      fakeRepo.oldMessagesResult = snapshot;

      final result = await useCase.execute(docId: 'chat-1');

      expect(result.conversationList.length, 2);
    });

    test('sets lastDocument to snapshot.docs.last', () async {
      await fakeFirestore
          .collection('messages')
          .doc('chat-1')
          .collection('conversations')
          .doc('m1')
          .set({
        'senderId': 'friend-1',
        'text': 'A',
        'dateTime': Timestamp.fromDate(DateTime(2024, 5, 1)),
      });
      await fakeFirestore
          .collection('messages')
          .doc('chat-1')
          .collection('conversations')
          .doc('m2')
          .set({
        'senderId': 'friend-1',
        'text': 'B',
        'dateTime': Timestamp.fromDate(DateTime(2024, 5, 1)),
      });

      final snapshot = await fakeFirestore
          .collection('messages')
          .doc('chat-1')
          .collection('conversations')
          .get();
      fakeRepo.oldMessagesResult = snapshot;

      final result = await useCase.execute(docId: 'chat-1');

      expect(result.lastDocument, isNotNull);
      expect(result.lastDocument!.id, snapshot.docs.last.id);
    });

    test('propagates errors from repository', () async {
      fakeRepo.oldMessagesError = Exception('query failed');

      expect(
            () => useCase.execute(docId: 'chat-1'),
        throwsA(isA<Exception>()),
      );
    });
  });
}