import 'package:cloud_firestore/cloud_firestore.dart';


abstract class HomeRepository {

  Future<DocumentSnapshot> getAccountData({required String docId});

  Stream<QuerySnapshot> getFriendsListStream({required String docId});

  Stream<QuerySnapshot> getUnreadMessagesStream({required String docId});

  Stream<QuerySnapshot> getLastMessageStream({required String friendId});
}