import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:test_app/features/home/domain/data_source/home_data_source.dart';
import 'package:test_app/features/home/data/data_source/home_data_source_impl.dart';


void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late HomeDataSource dataSource;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    dataSource = HomeDataSourceImpl(firestore: fakeFirestore);
  });

  group('getFriendsListStream', () {
    test('emits friends from the correct subcollection path', () async {
      await fakeFirestore
          .collection('users')
          .doc('user-1')
          .collection('friends')
          .doc('friend-1')
          .set({'name': 'Ali'});
      await fakeFirestore
          .collection('users')
          .doc('user-1')
          .collection('friends')
          .doc('friend-2')
          .set({'name': 'Sara'});

      final stream = dataSource.getFriendsListStream(
        docId: 'user-1',
        supCollection: 'users',
        subCollection: 'friends',
      );

      final snapshot = await stream.first;
      expect(snapshot.docs.length, 2);
      expect(snapshot.docs.map((d) => d.data()??['name']), containsAll(['Ali', 'Sara']));
    });

    test('does not include documents from other users', () async {
      await fakeFirestore
          .collection('users')
          .doc('user-1')
          .collection('friends')
          .doc('friend-1')
          .set({'name': 'Ali'});
      await fakeFirestore
          .collection('users')
          .doc('user-2')
          .collection('friends')
          .doc('friend-2')
          .set({'name': 'Sara'});

      final stream = dataSource.getFriendsListStream(
        docId: 'user-1',
        supCollection: 'users',
        subCollection: 'friends',
      );

      final snapshot = await stream.first;
      expect(snapshot.docs.length, 1);
      expect(snapshot.docs.first.data()??['name'], 'Ali');
    });
  });

  group('getLastMessageStream', () {
    test('returns only the most recent message (limit 1, desc order)',
            () async {
          await fakeFirestore.collection('messages').doc('m1').set({
            'participants': ['user-1', 'friend-1'],
            'text': 'Old',
            'createdAt': 1000,
          });
          await fakeFirestore.collection('messages').doc('m2').set({
            'participants': ['user-1', 'friend-1'],
            'text': 'New',
            'createdAt': 2000,
          });

          final stream = dataSource.getLastMessageStream(
            collectionPath: 'messages',
            whereField: 'participants',
            orderField: 'createdAt',
            friendId: 'friend-1',
          );

          final snapshot = await stream.first;
          expect(snapshot.docs.length, 1);
          expect(snapshot.docs.first.data()??['text'], 'New');
        });

    test('filters by arrayContains on the given whereField', () async {
      await fakeFirestore.collection('messages').doc('m1').set({
        'participants': ['user-1', 'friend-1'],
        'text': 'With friend-1',
        'createdAt': 1000,
      });
      await fakeFirestore.collection('messages').doc('m2').set({
        'participants': ['user-1', 'friend-2'],
        'text': 'With friend-2',
        'createdAt': 2000,
      });

      final stream = dataSource.getLastMessageStream(
        collectionPath: 'messages',
        whereField: 'participants',
        orderField: 'createdAt',
        friendId: 'friend-1',
      );

      final snapshot = await stream.first;
      expect(snapshot.docs.length, 1);
      expect(snapshot.docs.first.data()??['text'], 'With friend-1');
    });

    test('emits empty snapshot when no messages match', () async {
      final stream = dataSource.getLastMessageStream(
        collectionPath: 'messages',
        whereField: 'participants',
        orderField: 'createdAt',
        friendId: 'nonexistent',
      );

      final snapshot = await stream.first;
      expect(snapshot.docs, isEmpty);
    });
  });

  group('getUnreadMessagesStream', () {
    test('emits only unread messages (isEqualTo: true)', () async {
      await fakeFirestore
          .collection('chats')
          .doc('chat-1')
          .collection('messages')
          .doc('m1')
          .set({'isRead': false, 'text': 'Unread'});
      await fakeFirestore
          .collection('chats')
          .doc('chat-1')
          .collection('messages')
          .doc('m2')
          .set({'isRead': true, 'text': 'Read'});

      final stream = dataSource.getUnreadMessagesStream(
        supCollection: 'chats',
        subCollection: 'messages',
        whereField: 'isRead',
        docId: 'chat-1',
      );

      final snapshot = await stream.first;
      expect(snapshot.docs.length, 1);
      expect(snapshot.docs.first.data()??['text'], 'Unread');
    });

    test('uses the correct subcollection path', () async {
      await fakeFirestore
          .collection('chats')
          .doc('chat-1')
          .collection('messages')
          .doc('m1')
          .set({'isRead': false, 'text': 'Unread'});
      await fakeFirestore
          .collection('chats')
          .doc('chat-2')
          .collection('messages')
          .doc('m2')
          .set({'isRead': false, 'text': 'Other chat'});

      final stream = dataSource.getUnreadMessagesStream(
        supCollection: 'chats',
        subCollection: 'messages',
        whereField: 'isRead',
        docId: 'chat-1',
      );

      final snapshot = await stream.first;
      expect(snapshot.docs.length, 1);
      expect(snapshot.docs.first.data()??['text'], 'Unread');
    });
  });
}