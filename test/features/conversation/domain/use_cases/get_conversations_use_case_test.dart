import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import '../../../../fakes/fake_remote_conversation_repository.dart';
import 'package:test_app/features/conversation/data/models/data_model.dart';
import 'package:test_app/features/conversation/domain/use_cases/get_conversations_use_case.dart';


void main() {
  late FakeRemoteConversationRepository fakeRepo;
  late GetConversationsUseCase useCase;
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() {
    fakeRepo = FakeRemoteConversationRepository();
    fakeFirestore = FakeFirebaseFirestore();
    useCase = GetConversationsUseCase(repository: fakeRepo);
  });

  group('execute', () {
    test('emits empty DataModel when snapshot is empty', () async {
      final emptySnapshot = await fakeFirestore
          .collection('messages')
          .doc('chat-1')
          .collection('conversations')
          .get();
      fakeRepo.conversationsStream = Stream.value(emptySnapshot);

      final result = await useCase.execute(
        docId: 'chat-1',
        senderId: 'user-1',
      ).first;

      expect(result, isA<DataModel>());
      expect(result.conversationList, isEmpty);
      expect(result.firstDocument, isNull);
      expect(result.lastDocument, isNull);
    });

    test('filters out messages sent by the current user (senderId)', () async {
      await fakeFirestore
          .collection('messages')
          .doc('chat-1')
          .collection('conversations')
          .doc('m1')
          .set({
        'senderId': 'user-1',
        'text': 'My message',
        'dateTime': Timestamp.fromDate(DateTime(2024, 5, 1)),
      });
      await fakeFirestore
          .collection('messages')
          .doc('chat-1')
          .collection('conversations')
          .doc('m2')
          .set({
        'senderId': 'friend-1',
        'text': 'Friend message',
        'dateTime': Timestamp.fromDate(DateTime(2024, 5, 1)),
      });

      final snapshot = await fakeFirestore
          .collection('messages')
          .doc('chat-1')
          .collection('conversations')
          .get();
      fakeRepo.conversationsStream = Stream.value(snapshot);

      final result = await useCase.execute(
        docId: 'chat-1',
        senderId: 'user-1',
      ).first;

      // فقط رسالة friend-1
      expect(result.conversationList.length, 1);
      expect(result.conversationList.first.messages.length, 1);
      expect(result.conversationList.first.messages.first.text, 'Friend message');
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
      fakeRepo.conversationsStream = Stream.value(snapshot);

      final result = await useCase.execute(
        docId: 'chat-1',
        senderId: 'user-1',
      ).first;

      // reversed — Second قبل First
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
      fakeRepo.conversationsStream = Stream.value(snapshot);

      final result = await useCase.execute(
        docId: 'chat-1',
        senderId: 'user-1',
      ).first;

      expect(result.conversationList.length, 2);
    });

    test('passes endBeforeDocument and startAfterDocument to repository',
            () async {
          final emptySnapshot = await fakeFirestore
              .collection('messages')
              .doc('chat-1')
              .collection('conversations')
              .get();
          fakeRepo.conversationsStream = Stream.value(emptySnapshot);

          final firstDoc = await fakeFirestore
              .collection('messages')
              .doc('chat-1')
              .collection('conversations')
              .doc('d1')
              .get();
          final lastDoc = await fakeFirestore
              .collection('messages')
              .doc('chat-1')
              .collection('conversations')
              .doc('d2')
              .get();

          await useCase.execute(
            docId: 'chat-1',
            senderId: 'user-1',
            firstDocument: firstDoc,
            lastDocument: lastDoc,
          ).first;

          expect(fakeRepo.lastEndBeforeDocument, same(firstDoc));
          expect(fakeRepo.lastStartAfterDocument, same(lastDoc));
        });

    test('passes limit 15 when isEmptyList is true', () async {
      final emptySnapshot = await fakeFirestore
          .collection('messages')
          .doc('chat-1')
          .collection('conversations')
          .get();
      fakeRepo.conversationsStream = Stream.value(emptySnapshot);

      await useCase.execute(
        docId: 'chat-1',
        senderId: 'user-1',
        isEmptyList: true,
      ).first;

      expect(fakeRepo.lastLimit, 15);
    });

    test('passes limit null when isEmptyList is false', () async {
      final emptySnapshot = await fakeFirestore
          .collection('messages')
          .doc('chat-1')
          .collection('conversations')
          .get();
      fakeRepo.conversationsStream = Stream.value(emptySnapshot);

      await useCase.execute(
        docId: 'chat-1',
        senderId: 'user-1',
        isEmptyList: false,
      ).first;

      expect(fakeRepo.lastLimit, isNull);
    });
  });
}