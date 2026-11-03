import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_app/features/conversation/data/models/conversation_model.dart';
import 'package:test_app/features/conversation/domain/repositories/remote_conversation_repository.dart';


class FakeRemoteConversationRepository implements RemoteConversationRepository {
  // ===== deleteMessages =====
  int deleteMessagesCallCount = 0;
  String? lastDeleteDocId;
  List<String>? lastMessagesIds;
  Object? deleteMessagesError;

  @override
  Future<void> deleteMessages({
    required String docId,
    required List<String> messagesIds,
  }) async {
    deleteMessagesCallCount++;
    lastDeleteDocId = docId;
    lastMessagesIds = messagesIds;
    if (deleteMessagesError != null) throw deleteMessagesError!;
  }

  // ===== getConversationsStream =====
  Stream<QuerySnapshot>? conversationsStream;
  int getConversationsStreamCallCount = 0;
  String? lastConversationsDocId;
  DocumentSnapshot? lastEndBeforeDocument;
  DocumentSnapshot? lastStartAfterDocument;
  int? lastLimit;

  @override
  Stream<QuerySnapshot> getConversationsStream({
    required String docId,
    DocumentSnapshot? startAfterDocument,
    DocumentSnapshot? endBeforeDocument,
    int? limit,
  }) {
    getConversationsStreamCallCount++;
    lastConversationsDocId = docId;
    lastStartAfterDocument = startAfterDocument;
    lastEndBeforeDocument = endBeforeDocument;
    lastLimit = limit;
    return conversationsStream!;
  }

  // ===== getOldMessagesQuery =====
  QuerySnapshot? oldMessagesResult;
  int getOldMessagesQueryCallCount = 0;
  String? lastOldMessagesDocId;
  DocumentSnapshot? lastOldMessagesLastDocument;
  int? lastOldMessagesLimit;
  Object? oldMessagesError;

  @override
  Future<QuerySnapshot> getOldMessagesQuery({
    required String docId,
    DocumentSnapshot? lastDocument,
    int limit = 15,
  }) async {
    getOldMessagesQueryCallCount++;
    lastOldMessagesDocId = docId;
    lastOldMessagesLastDocument = lastDocument;
    lastOldMessagesLimit = limit;
    return oldMessagesResult!;
  }

  int sendMessageCallCount = 0;
  String? lastSendDocId;
  ConversationModel? lastSendConversation;
  Object? sendMessageError;

  @override
  Future<void> sendMessage({
    required String docId,
    required ConversationModel conversation,
  }) async {
    sendMessageCallCount++;
    lastSendDocId = docId;
    lastSendConversation = conversation;
    if (sendMessageError != null) throw sendMessageError!;
  }

  int updateTypingStatusCallCount = 0;
  String? lastTypingUserId;
  bool? lastIsTyping;
  Object? updateTypingStatusError;

  @override
  Future<void> updateTypingStatus({
    required String userId,
    required bool isTyping,
  }) async {
    updateTypingStatusCallCount++;
    lastTypingUserId = userId;
    lastIsTyping = isTyping;
    if (updateTypingStatusError != null) throw updateTypingStatusError!;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(
        'FakeRemoteConversationRepository.${invocation.memberName} not stubbed',
      );
}