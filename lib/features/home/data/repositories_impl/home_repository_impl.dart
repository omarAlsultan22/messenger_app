import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/data_source/home_data_source.dart';
import 'package:test_app/features/home/domain/repositories/home_repository.dart';


class HomeRepositoryImpl implements HomeRepository{
  final HomeDataSource _dataSource;

  HomeRepositoryImpl({required HomeDataSource dataSource})
      : _dataSource = dataSource;

  @override
  Future<DocumentSnapshot> getAccountData({required String docId}) async {
    final getData = await _dataSource.getDocument(
        collectionPath: 'accounts', docId: docId);
    return getData;
  }

  @override
  Stream<QuerySnapshot> getFriendsListStream({required String docId}) {
    return _dataSource.getFriendsListStream(
      supCollection: 'users',
      subCollection: 'friends',
      docId: docId,
    );
  }

  @override
  Stream<QuerySnapshot> getLastMessageStream({required String friendId}) {
    return _dataSource.getLastMessageStream(
        collectionPath: 'messages',
        whereField: 'participants',
        orderField: 'lastMessageDateTime',
        friendId: friendId
    );
  }

  @override
  Stream<QuerySnapshot> getUnreadMessagesStream({required String docId}) {
    return _dataSource.getUnreadMessagesStream(
        supCollection: 'messages',
        subCollection: 'conversations',
        whereField: 'unreadMessage',
        docId: docId
    );
  }
}