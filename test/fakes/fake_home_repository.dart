import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_app/features/home/domain/repositories/home_repository.dart';


class FakeHomeRepository implements HomeRepository {
  // ===== getAccountData =====
  DocumentSnapshot? accountDataResult;

  @override
  Future<DocumentSnapshot> getAccountData({required String docId}) async {
    return accountDataResult!;
  }

  // ===== getFriendsListStream =====
  Stream<QuerySnapshot>? friendsListStream;
  int getFriendsListCallCount = 0;
  String? lastFriendsDocId;

  @override
  Stream<QuerySnapshot> getFriendsListStream({required String docId}) {
    getFriendsListCallCount++;
    lastFriendsDocId = docId;
    return friendsListStream!;
  }

  // ===== getLastMessageStream =====
  Stream<QuerySnapshot>? lastMessageStream;
  int getLastMessageCallCount = 0;
  String? lastLastMessageFriendId;

  @override
  Stream<QuerySnapshot> getLastMessageStream({required String friendId}) {
    getLastMessageCallCount++;
    lastLastMessageFriendId = friendId;
    return lastMessageStream!;
  }

  // ===== getUnreadMessagesStream =====
  Stream<QuerySnapshot>? unreadMessagesStream;
  int getUnreadMessagesCallCount = 0;
  String? lastUnreadDocId;

  @override
  Stream<QuerySnapshot> getUnreadMessagesStream({required String docId}) {
    getUnreadMessagesCallCount++;
    lastUnreadDocId = docId;
    return unreadMessagesStream!;
  }
}