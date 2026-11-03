import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:test_app/core/domain/data_sources/firestore/firestore_service.dart';
import 'package:test_app/core/data/data_sources/remote/firestore/firestore_service_impl.dart';


void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late FirestoreService service;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    service = FirestoreServiceImpl(firestore: fakeFirestore);
  });

  group('createDoc', () {
    test('returns a DocumentReference with auto-generated id', () async {
      final ref = service.createDoc(collectionPath: 'users');

      expect(ref.id, isNotEmpty);
      expect(ref.path, startsWith('users/'));
    });

    test('creates a new reference on each call (different ids)', () async {
      final ref1 = service.createDoc(collectionPath: 'users');
      final ref2 = service.createDoc(collectionPath: 'users');

      expect(ref1.id, isNot(ref2.id));
    });
  });

  group('addData', () {
    test('adds data and returns the generated doc id', () async {
      final id = await service.addData(
        collectionPath: 'users',
        data: {'name': 'Ali', 'age': 25},
      );

      expect(id, isNotEmpty);

      final snapshot =
      await fakeFirestore.collection('users').doc(id).get();
      expect(snapshot.data()?['name'], 'Ali');
    });

    test('adds multiple documents independently', () async {
      final id1 = await service.addData(
        collectionPath: 'users',
        data: {'name': 'A'},
      );
      final id2 = await service.addData(
        collectionPath: 'users',
        data: {'name': 'B'},
      );

      expect(id1, isNot(id2));
    });
  });

  group('setData', () {
    test('sets data at the given doc id', () async {
      await service.setData(
        collectionPath: 'users',
        docId: 'user-1',
        data: {'name': 'Ali'},
      );

      final snapshot =
      await fakeFirestore.collection('users').doc('user-1').get();
      expect(snapshot.exists, true);
      expect(snapshot.data()?['name'], 'Ali');
    });

    test('overwrites existing document', () async {
      await fakeFirestore
          .collection('users')
          .doc('user-1')
          .set({'name': 'Old', 'age': 20});

      await service.setData(
        collectionPath: 'users',
        docId: 'user-1',
        data: {'name': 'New'},
      );

      final snapshot =
      await fakeFirestore.collection('users').doc('user-1').get();
      expect(snapshot.data(), {'name': 'New'}); // 'age' اختفى
    });
  });

  group('getSubCollection', () {
    test('returns a Query for the correct subcollection path', () async {
      await fakeFirestore
          .collection('users')
          .doc('user-1')
          .collection('posts')
          .doc('post-1')
          .set({'title': 'Hello'});

      final query = service.getSubCollection(
        collectionPath: 'users',
        docId: 'user-1',
        subCollectionPath: 'posts',
      );

      final result = await query.get();
      expect(result.docs.length, 1);
      expect(result.docs.first.data()['title'], 'Hello');
    });

    test('does not include supercollection documents', () async {
      await fakeFirestore
          .collection('users')
          .doc('user-1')
          .set({'name': 'Ali'});

      final query = service.getSubCollection(
        collectionPath: 'users',
        docId: 'user-1',
        subCollectionPath: 'posts',
      );

      final result = await query.get();
      expect(result.docs, isEmpty);
    });
  });

  group('updateDoc', () {
    test('updates existing document fields', () async {
      await fakeFirestore
          .collection('users')
          .doc('user-1')
          .set({'name': 'Ali', 'age': 25});

      await service.updateDoc(
        docId: 'user-1',
        collectionPath: 'users',
        data: {'age': 26},
      );

      final snapshot =
      await fakeFirestore.collection('users').doc('user-1').get();
      expect(snapshot.data()?['name'], 'Ali'); // لم يتغير
      expect(snapshot.data()?['age'], 26);     // تغير
    });

    test('throws when document does not exist', () async {
      expect(
            () => service.updateDoc(
          docId: 'missing',
          collectionPath: 'users',
          data: {'name': 'X'},
        ),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('deleteDocument', () {
    test('removes the document', () async {
      await fakeFirestore
          .collection('users')
          .doc('user-1')
          .set({'name': 'Ali'});

      await service.deleteDocument(
        collectionPath: 'users',
        docId: 'user-1',
      );

      final snapshot =
      await fakeFirestore.collection('users').doc('user-1').get();
      expect(snapshot.exists, false);
    });

    test('completes without error when document does not exist', () async {
      await expectLater(
        service.deleteDocument(
          collectionPath: 'users',
          docId: 'missing',
        ),
        completes,
      );
    });
  });

  group('inherited getDocument (from FirestoreOperationsImpl)', () {
    test('still works with injected firestore', () async {
      await fakeFirestore
          .collection('users')
          .doc('user-1')
          .set({'name': 'Ali'});

      final snapshot = await service.getDocument(
        collectionPath: 'users',
        docId: 'user-1',
      );

      expect(snapshot.exists, true);
      expect(snapshot.data()?['name'], 'Ali');
    });
  });
}