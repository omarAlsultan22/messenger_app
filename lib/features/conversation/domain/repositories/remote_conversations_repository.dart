import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/conversation_model.dart';


abstract class RemoteConversationsRepository {

  Future<void> updateUnreadMessages({required String docId});

  Stream<QuerySnapshot> getConversationsStream({
    required String docId,
    DocumentSnapshot? startAfterDocument,
    DocumentSnapshot? endBeforeDocument,
    int? limit,
  });

  Future<QuerySnapshot> getOldMessagesQuery({
    required String docId,
    DocumentSnapshot? lastDocument,
    int limit = 15,
  });

  Future<void> updateTypingStatus({
    required String userId,
    required bool isTyping});

  Future<void> clearConversations({required String docId});

  Future<void> deleteMessages({
    required String docId,
    required List<String> messagesIds,
  });

  Future<void> sendMessage({
    required String docId,
    required ConversationModel conversation,
  });

  DocumentReference getMessageDocumentReference({
    required String docId,
    required String messageId
  });
}