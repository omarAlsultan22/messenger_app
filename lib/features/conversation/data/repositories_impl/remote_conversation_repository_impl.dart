import '../models/conversation_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/data_sources/conversation_data_source.dart';
import 'package:test_app/features/conversation/domain/repositories/remote_conversation_repository.dart';


class RemoteConversationRepositoryImpl implements RemoteConversationRepository {
  final ConversationDataSource _dataSource;

  RemoteConversationRepositoryImpl({
    required ConversationDataSource dataSource,
  }) : _dataSource = dataSource;

  @override
  Future<void> updateUnreadMessages({required String docId}) async {
    await _dataSource.updateUnreadMessages(docId: docId);
  }

  @override
  Stream<QuerySnapshot> getConversationsStream({
    required String docId,
    DocumentSnapshot? startAfterDocument,
    DocumentSnapshot? endBeforeDocument,
    int? limit,
  }) {
    return _dataSource.getConversationsStream(docId: docId);
  }

  @override
  Future<QuerySnapshot> getOldMessagesQuery({
    required String docId,
    DocumentSnapshot? lastDocument,
    int limit = 15,
  }) async {
    return await _dataSource.getOldMessagesQuery(docId: docId);
  }

  @override
  Future<void> updateTypingStatus({
    required String userId,
    required bool isTyping
  }) async {
    await _dataSource.updateTypingStatus(userId: userId, isTyping: isTyping);
  }

  @override
  Future<void> clearConversations({required String docId}) async {
    await _dataSource.clearConversations(docId: docId);
  }

  @override
  Future<void> deleteMessages({
    required String docId,
    required List<String> messagesIds,
  }) async {
    await _dataSource.deleteMessages(docId: docId, messagesIds: messagesIds);
  }

  @override
  Future<void> sendMessage({
    required String docId,
    required ConversationModel conversation,
  }) async {
    await _dataSource.sendMessage(docId: docId, conversation: conversation);
  }

  @override
  DocumentReference getMessageDocumentReference({
    required String docId,
    required String messageId
  }) {
    return _dataSource.getMessageDocumentReference(
        docId: docId, messageId: messageId);
  }
}