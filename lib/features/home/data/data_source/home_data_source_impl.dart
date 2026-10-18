import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_app/features/home/domain/data_source/home_data_source.dart';
import 'package:test_app/core/data/data_sources/remote/firestore/firestore_operations_impl.dart';


class HomeDataSourceImpl extends FirestoreOperationsImpl implements HomeDataSource{
  @override
  Stream<QuerySnapshot> getFriendsListStream({
    required String docId,
    required String supCollection,
    required String subCollection
  }) {
    return firestore.collection(supCollection)
        .doc(docId)
        .collection(subCollection)
        .snapshots();
  }

  @override
  Stream<QuerySnapshot> getLastMessageStream({
    required String collectionPath,
    required String whereField,
    required String orderField,
    required String friendId
  }) {
    return firestore
        .collection(collectionPath)
        .where(whereField, arrayContains: friendId)
        .orderBy(orderField, descending: true)
        .limit(1)
        .snapshots();
  }

  @override
  Stream<QuerySnapshot> getUnreadMessagesStream({
    required String supCollection,
    required String subCollection,
    required String whereField,
    required String docId,
  }) {
    return firestore
        .collection(supCollection)
        .doc(docId)
        .collection(subCollection)
        .where(whereField, isEqualTo: true)
        .snapshots();
  }
}