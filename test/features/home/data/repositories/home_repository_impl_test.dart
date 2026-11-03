import 'package:flutter_test/flutter_test.dart';
import '../../../../fakes/fake_home_data_source.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:test_app/features/home/domain/repositories/home_repository.dart';
import 'package:test_app/features/home/data/repositories_impl/home_repository_impl.dart';


void main() {
  late HomeRepository repository;
  late FakeHomeDataSource fakeDataSource;
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() {
    fakeDataSource = FakeHomeDataSource();
    fakeFirestore = FakeFirebaseFirestore();
    repository = HomeRepositoryImpl(dataSource: fakeDataSource);
  });

  group('getAccountData', () {
    test('calls getDocument with "accounts" collection and given docId',
            () async {
          await fakeFirestore
              .collection('accounts')
              .doc('user-1')
              .set({'name': 'Ali'});
          final doc = await fakeFirestore.collection('accounts').doc('user-1').get();
          fakeDataSource.documentToReturn = doc;

          final result = await repository.getAccountData(docId: 'user-1');

          expect(result, same(doc));
          expect(fakeDataSource.getDocumentCallCount, 1);
          expect(fakeDataSource.lastDocumentCollectionPath, 'accounts');
          expect(fakeDataSource.lastDocumentDocId, 'user-1');
        });

    test('propagates errors from getDocument', () async {
      fakeDataSource.getDocumentError = Exception('read failed');

      expect(
            () => repository.getAccountData(docId: 'user-1'),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('getFriendsListStream', () {
    test('calls getFriendsListStream with "users"/"friends" paths', () async {
      fakeDataSource.friendsListStream = const Stream.empty();

      repository.getFriendsListStream(docId: 'user-1');

      expect(fakeDataSource.getFriendsListCallCount, 1);
      expect(fakeDataSource.lastFriendsSupCollection, 'users');
      expect(fakeDataSource.lastFriendsSubCollection, 'friends');
      expect(fakeDataSource.lastFriendsDocId, 'user-1');
    });
  });

  group('getLastMessageStream', () {
    test('calls getLastMessageStream with correct params', () async {
      fakeDataSource.lastMessageStream = const Stream.empty();

      repository.getLastMessageStream(friendId: 'friend-1');

      expect(fakeDataSource.getLastMessageCallCount, 1);
      expect(fakeDataSource.lastMessagesCollectionPath, 'messages');
      expect(fakeDataSource.lastMessagesWhereField, 'participants');
      expect(fakeDataSource.lastMessagesOrderField, 'lastMessageDateTime');
      expect(fakeDataSource.lastMessagesFriendId, 'friend-1');
    });
  });

  group('getUnreadMessagesStream', () {
    test('calls getUnreadMessagesStream with correct params', () async {
      fakeDataSource.unreadMessagesStream = const Stream.empty();

      repository.getUnreadMessagesStream(docId: 'user-1');

      expect(fakeDataSource.getUnreadMessagesCallCount, 1);
      expect(fakeDataSource.lastUnreadSupCollection, 'messages');
      expect(fakeDataSource.lastUnreadSubCollection, 'conversations');
      expect(fakeDataSource.lastUnreadWhereField, 'unreadMessage');
      expect(fakeDataSource.lastUnreadDocId, 'user-1');
    });
  });
}