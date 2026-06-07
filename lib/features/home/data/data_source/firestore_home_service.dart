import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/data/data_sources/remote/firestore/firestore_base_operations.dart';


class FirestoreHomeService extends FirestoreBaseOperations{
  static final _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getFriendsListStream({
    required String docId,
    required String supCollection,
    required String subCollection
  }) {
    return _firestore.collection(supCollection)
        .doc(docId)
        .collection(subCollection)
        .snapshots();
  }

  Stream<QuerySnapshot> getLastMessageStream({
    required String collectionPath,
    required String whereField,
    required String orderField,
    required String friendId
  }) {
    return _firestore
        .collection(collectionPath)
        .where(whereField, arrayContains: friendId)
        .orderBy(orderField, descending: true)
        .limit(1)
        .snapshots();
  }

  Stream<QuerySnapshot> getUnreadMessagesStream({
    required String supCollection,
    required String subCollection,
    required String whereField,
    required String docId,
  }) {
    return _firestore
        .collection(supCollection)
        .doc(docId)
        .collection(subCollection)
        .where(whereField, isEqualTo: true)
        .snapshots();
  }
}