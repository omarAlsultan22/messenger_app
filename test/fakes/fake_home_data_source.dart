import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_app/features/home/domain/data_source/home_data_source.dart';


class FakeHomeDataSource implements HomeDataSource {
  // ===== getDocument =====
  DocumentSnapshot<Map<String, dynamic>>? documentToReturn;
  Object? getDocumentError;
  int getDocumentCallCount = 0;
  String? lastDocumentCollectionPath;
  String? lastDocumentDocId;

  @override
  Future<DocumentSnapshot<Map<String, dynamic>>> getDocument({
    required String collectionPath,
    required String? docId,
  }) async {
    getDocumentCallCount++;
    lastDocumentCollectionPath = collectionPath;
    lastDocumentDocId = docId;
    if (getDocumentError != null) throw getDocumentError!;
    return documentToReturn!;
  }

  // ===== getFriendsListStream =====
  Stream<QuerySnapshot<Map<String, dynamic>>>? friendsListStream;
  int getFriendsListCallCount = 0;
  String? lastFriendsSupCollection;
  String? lastFriendsSubCollection;
  String? lastFriendsDocId;

  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> getFriendsListStream({
    required String docId,
    required String supCollection,
    required String subCollection,
  }) {
    getFriendsListCallCount++;
    lastFriendsDocId = docId;
    lastFriendsSupCollection = supCollection;
    lastFriendsSubCollection = subCollection;
    return friendsListStream!;
  }

  // ===== getLastMessageStream =====
  Stream<QuerySnapshot<Map<String, dynamic>>>? lastMessageStream;
  int getLastMessageCallCount = 0;
  String? lastMessagesCollectionPath;
  String? lastMessagesWhereField;
  String? lastMessagesOrderField;
  String? lastMessagesFriendId;

  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessageStream({
    required String collectionPath,
    required String whereField,
    required String orderField,
    required String friendId,
  }) {
    getLastMessageCallCount++;
    lastMessagesCollectionPath = collectionPath;
    lastMessagesWhereField = whereField;
    lastMessagesOrderField = orderField;
    lastMessagesFriendId = friendId;
    return lastMessageStream!;
  }

  // ===== getUnreadMessagesStream =====
  Stream<QuerySnapshot<Map<String, dynamic>>>? unreadMessagesStream;
  int getUnreadMessagesCallCount = 0;
  String? lastUnreadSupCollection;
  String? lastUnreadSubCollection;
  String? lastUnreadWhereField;
  String? lastUnreadDocId;

  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> getUnreadMessagesStream({
    required String supCollection,
    required String subCollection,
    required String whereField,
    required String docId,
  }) {
    getUnreadMessagesCallCount++;
    lastUnreadSupCollection = supCollection;
    lastUnreadSubCollection = subCollection;
    lastUnreadWhereField = whereField;
    lastUnreadDocId = docId;
    return unreadMessagesStream!;
  }
}