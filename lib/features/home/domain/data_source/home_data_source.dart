import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/domain/data_sources/firestore/firestore_operations.dart';


abstract class HomeDataSource implements FirestoreOperations{
  Stream<QuerySnapshot> getFriendsListStream({
    required String docId,
    required String supCollection,
    required String subCollection
  });

  Stream<QuerySnapshot> getLastMessageStream({
    required String collectionPath,
    required String whereField,
    required String orderField,
    required String friendId
  });

  Stream<QuerySnapshot> getUnreadMessagesStream({
    required String supCollection,
    required String subCollection,
    required String whereField,
    required String docId,
  });
}