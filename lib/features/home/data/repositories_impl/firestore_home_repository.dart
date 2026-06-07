import 'dart:async';
import '../data_source/firestore_home_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_app/features/home/domain/repositories/home_repository.dart';


class FirestoreHomeRepository implements HomeRepository{
  final FirestoreHomeService _service;

  FirestoreHomeRepository({required FirestoreHomeService service})
      : _service = service;

  @override
  Future<DocumentSnapshot> getAccountData({required String docId}) async {
    final getData = await _service.getDocument(
        collectionPath: 'accounts', docId: docId);
    return getData;
  }

  @override
  Stream<QuerySnapshot> getFriendsListStream({required String docId}) {
    return _service.getFriendsListStream(
      supCollection: 'users',
      subCollection: 'friends',
      docId: docId,
    );
  }

  @override
  Stream<QuerySnapshot> getLastMessageStream({required String friendId}) {
    return _service.getLastMessageStream(
        collectionPath: 'messages',
        whereField: 'participants',
        orderField: 'lastMessageDateTime',
        friendId: friendId
    );
  }

  @override
  Stream<QuerySnapshot> getUnreadMessagesStream({required String docId}) {
    return _service.getUnreadMessagesStream(
        supCollection: 'messages',
        subCollection: 'conversations',
        whereField: 'unreadMessage',
        docId: docId
    );
  }
}