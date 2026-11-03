import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:test_app/core/domain/data_sources/firestore/firestore_operations.dart';
import 'package:test_app/core/data/data_sources/remote/firestore/firestore_operations_impl.dart';


void main() {
  late FirestoreOperations operations;
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    operations = FirestoreOperationsImpl(firestore: fakeFirestore);
  });

  group('getDocument', () {
    test('returns the document snapshot when it exists', () async {
      await fakeFirestore
          .collection('users')
          .doc('user-1')
          .set({'name': 'Ali', 'age': 25});

      final snapshot = await operations.getDocument(
        collectionPath: 'users',
        docId: 'user-1',
      );

      expect(snapshot.exists, true);
      expect(snapshot.data()?['name'], 'Ali');
      expect(snapshot.data()?['age'], 25);
    });

    test('returns non-existing snapshot when document is missing', () async {
      final snapshot = await operations.getDocument(
        collectionPath: 'users',
        docId: 'missing',
      );

      expect(snapshot.exists, false);
      expect(snapshot.data(), isNull);
    });

    test('uses the correct collection path', () async {
      await fakeFirestore
          .collection('posts')
          .doc('post-1')
          .set({'title': 'Hello'});

      final snapshot = await operations.getDocument(
        collectionPath: 'posts',
        docId: 'post-1',
      );

      expect(snapshot.data()?['title'], 'Hello');
    });

    test('handles null docId gracefully', () async {
      // Firestore يرفض doc(null) عادةً — نتحقق من السلوك
      expect(
            () =>
            operations.getDocument(
              collectionPath: 'users',
              docId: null,
            ),
        throwsA(anything),
      );
    });

    test('returns nested document data correctly', () async {
      await fakeFirestore.collection('users').doc('user-1').set({
        'profile': {'name': 'Ali', 'age': 25},
        'active': true,
      });

      final snapshot = await operations.getDocument(
        collectionPath: 'users',
        docId: 'user-1',
      );

      final data = snapshot.data()!;
      expect(data['profile'], {'name': 'Ali', 'age': 25});
      expect(data['active'], true);
    });
  });
}