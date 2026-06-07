import '../models/conversation_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data_sources/remote/firestore_conversation.dart';
import 'package:test_app/features/conversation/domain/repositories/remote_conversations_repository.dart';


class FirestoreConversationRepository implements RemoteConversationsRepository {
  final FirestoreConversationService _service;

  FirestoreConversationRepository({
    required FirestoreConversationService service,
  }) : _service = service;

  @override
  Future<void> updateUnreadMessages({required String docId}) async {
    await _service.updateUnreadMessages(docId: docId);
  }

  @override
  Stream<QuerySnapshot> getConversationsStream({
    required String docId,
    DocumentSnapshot? startAfterDocument,
    DocumentSnapshot? endBeforeDocument,
    int? limit,
  }) {
    return _service.getConversationsStream(docId: docId);
  }

  @override
  Future<QuerySnapshot> getOldMessagesQuery({
    required String docId,
    DocumentSnapshot? lastDocument,
    int limit = 15,
  }) async {
    return await _service.getOldMessagesQuery(docId: docId);
  }

  @override
  Future<void> updateTypingStatus({
    required String userId,
    required bool isTyping
  }) async {
    await _service.updateTypingStatus(userId: userId, isTyping: isTyping);
  }

  @override
  Future<void> clearConversations({required String docId}) async {
    await _service.clearConversations(docId: docId);
  }

  @override
  Future<void> deleteMessages({
    required String docId,
    required List<String> messagesIds,
  }) async {
    await _service.deleteMessages(docId: docId, messagesIds: messagesIds);
  }

  @override
  Future<void> sendMessage({
    required String docId,
    required ConversationModel conversation,
  }) async {
    await _service.sendMessage(docId: docId, conversation: conversation);
  }

  @override
  DocumentReference getMessageDocumentReference({
    required String docId,
    required String messageId
  }) {
    return _service.getMessageDocumentReference(
        docId: docId, messageId: messageId);
  }
}