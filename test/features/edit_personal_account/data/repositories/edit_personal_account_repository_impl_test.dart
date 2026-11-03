import 'package:flutter_test/flutter_test.dart';
import '../../../../fakes/fake_firestore_service.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:test_app/features/edit_personal_account/data/repositories_impl/edit_personal_account_repository_impl.dart';


void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late FakeFirestoreService fakeDataSource;
  late EditPersonalAccountRepositoryImpl repository;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    fakeDataSource = FakeFirestoreService();
    repository = EditPersonalAccountRepositoryImpl(dataSource: fakeDataSource);
  });

  group('getAccountData', () {
    test('fetches both "accounts" and "info" documents in parallel',
            () async {
          // نضع مستندين في fakeFirestore
          await fakeFirestore.collection('accounts').doc('user-1').set({'name': 'Ali'});
          await fakeFirestore.collection('info').doc('user-1').set({'userState': 'public'});

          final accountsDoc = await fakeFirestore.collection('accounts').doc('user-1').get();
          final infoDoc = await fakeFirestore.collection('info').doc('user-1').get();

          fakeDataSource.stubDoc(
            collectionPath: 'accounts',
            docId: 'user-1',
            snapshot: accountsDoc,
          );
          fakeDataSource.stubDoc(
            collectionPath: 'info',
            docId: 'user-1',
            snapshot: infoDoc,
          );

          final result = await repository.getAccountData(userId: 'user-1');

          expect(result.length, 2);
          expect(result[0].data()?['name'], 'Ali');
          expect(result[1].data()?['userState'], 'public');
        });

    test('propagates errors from getDocument', () async {
      fakeDataSource.getDocumentError = Exception('read failed');

      expect(
            () => repository.getAccountData(userId: 'user-1'),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('updateAccountData', () {
    test('creates post, updates account and info documents', () async {
      await fakeFirestore.collection('posts').doc('post-1').set({});
      final postRef = fakeFirestore.collection('posts').doc('post-1');
      fakeDataSource.createDocResult = postRef;

      repository.updateAccountData(
        userId: 'user-1',
        userImage: 'https://example.com/avatar.jpg',
        firstName: 'Ali',
        lastName: 'Ahmed',
        userState: 'public',
      );

      // انتظر Future.wait (لأن updateAccountData void)
      await Future.delayed(Duration.zero);

      expect(fakeDataSource.addDataCallCount, 1);
      expect(fakeDataSource.updateDocCallCount, 2);
    });

    test('constructs PostModel with correct fields', () async {
      final postRef = fakeFirestore.collection('posts').doc('post-1');
      fakeDataSource.createDocResult = postRef;

      repository.updateAccountData(
        userId: 'user-1',
        userImage: 'https://example.com/avatar.jpg',
        firstName: 'Ali',
        lastName: 'Ahmed',
        userState: 'public',
      );

      await Future.delayed(Duration.zero);

      final postData = fakeDataSource.lastAddData!;
      expect(postData['userId'], 'user-1');
      expect(postData['docId'], 'post-1');
      expect(postData['postType'], 'profileImage');
      expect(postData['userPost'], 'https://example.com/avatar.jpg');
      expect(postData['userState'], 'public');
    });

    test('constructs UserModel with correct fullName and userImage path',
            () async {
          final postRef = fakeFirestore.collection('posts').doc('post-1');
          fakeDataSource.createDocResult = postRef;

          repository.updateAccountData(
            userId: 'user-1',
            userImage: 'https://example.com/avatar.jpg',
            firstName: 'Ali',
            lastName: 'Ahmed',
            userState: 'public',
          );

          await Future.delayed(Duration.zero);

          // updateDoc يُستدعى مرتين — أول مرة accounts (UserModel)، ثاني مرة info
          final accountUpdate = fakeDataSource.updateDocCalls.firstWhere(
                (call) => call.collectionPath == 'accounts',
          );
          expect(accountUpdate.data['firstName'], 'Ali');
          expect(accountUpdate.data['lastName'], 'Ahmed');
          expect(accountUpdate.data['fullName'], 'AliAhmed');
          expect(accountUpdate.data['userImage'], 'posts/post-1');
        });

    test('updates info document with userState', () async {
      final postRef = fakeFirestore.collection('posts').doc('post-1');
      fakeDataSource.createDocResult = postRef;

      repository.updateAccountData(
        userId: 'user-1',
        userImage: 'https://example.com/avatar.jpg',
        firstName: 'Ali',
        lastName: 'Ahmed',
        userState: 'private',
      );

      await Future.delayed(Duration.zero);

      final infoUpdate = fakeDataSource.updateDocCalls.firstWhere(
            (call) => call.collectionPath == 'info',
      );
      expect(infoUpdate.data, {'userState': 'private'});
    });
  });
}