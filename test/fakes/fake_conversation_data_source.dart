import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_app/features/conversation/data/models/conversation_model.dart';
import 'package:test_app/features/conversation/domain/data_sources/conversation_data_source.dart';


class FakeConversationDataSource implements ConversationDataSource {
  // ===== updateUnreadMessages =====
  int updateUnreadMessagesCallCount = 0;
  String? lastUnreadDocId;

  @override
  Future<void> updateUnreadMessages({required String docId}) async {
    updateUnreadMessagesCallCount++;
    lastUnreadDocId = docId;
  }

  // ===== getConversationsStream =====
  Stream<QuerySnapshot>? conversationsStream;
  int getConversationsStreamCallCount = 0;
  String? lastConversationsDocId;

  @override
  Stream<QuerySnapshot> getConversationsStream({
    required String docId,
    DocumentSnapshot? startAfterDocument,
    DocumentSnapshot? endBeforeDocument,
    int? limit,
  }) {
    getConversationsStreamCallCount++;
    lastConversationsDocId = docId;
    return conversationsStream!;
  }

  // ===== getOldMessagesQuery =====
  QuerySnapshot? oldMessagesResult;
  int getOldMessagesQueryCallCount = 0;
  String? lastOldMessagesDocId;

  @override
  Future<QuerySnapshot> getOldMessagesQuery({
    required String docId,
    DocumentSnapshot? lastDocument,
    int limit = 15,
  }) async {
    getOldMessagesQueryCallCount++;
    lastOldMessagesDocId = docId;
    return oldMessagesResult!;
  }

  // ===== updateTypingStatus =====
  int updateTypingStatusCallCount = 0;
  String? lastTypingUserId;
  bool? lastIsTyping;

  @override
  Future<void> updateTypingStatus({
    required String userId,
    required bool isTyping,
  }) async {
    updateTypingStatusCallCount++;
    lastTypingUserId = userId;
    lastIsTyping = isTyping;
  }

  // ===== clearConversations =====
  int clearConversationsCallCount = 0;
  String? lastClearDocId;

  @override
  Future<void> clearConversations({required String docId}) async {
    clearConversationsCallCount++;
    lastClearDocId = docId;
  }

  // ===== deleteMessages =====
  int deleteMessagesCallCount = 0;
  String? lastDeleteDocId;
  List<String>? lastMessagesIds;

  @override
  Future<void> deleteMessages({
    required String docId,
    required List<String> messagesIds,
  }) async {
    deleteMessagesCallCount++;
    lastDeleteDocId = docId;
    lastMessagesIds = messagesIds;
  }

  // ===== sendMessage =====
  int sendMessageCallCount = 0;
  String? lastSendDocId;
  ConversationModel? lastConversation;

  @override
  Future<void> sendMessage({
    required String docId,
    required ConversationModel conversation,
  }) async {
    sendMessageCallCount++;
    lastSendDocId = docId;
    lastConversation = conversation;
  }

  // ===== getMessageDocumentReference =====
  DocumentReference? messageDocumentReference;
  String? lastMessageRefDocId;
  String? lastMessageRefMessageId;

  @override
  DocumentReference getMessageDocumentReference({
    required String docId,
    required String messageId,
  }) {
    lastMessageRefDocId = docId;
    lastMessageRefMessageId = messageId;
    return messageDocumentReference!;
  }
}