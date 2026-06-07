import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/conversation_model.dart';


class FirestoreConversationService {
  static final _firestore = FirebaseFirestore.instance;

  Future<void> updateUnreadMessages({required String docId}) async {
    final unreadMessages = await _firestore
        .collection('messages')
        .doc(docId)
        .collection('conversations')
        .where('unreadMessage', isEqualTo: true)
        .get();

    for (final unreadMessage in unreadMessages.docs) {
      await _firestore
          .collection('messages')
          .doc(docId)
          .collection('conversations')
          .doc(unreadMessage.id)
          .update({'unreadMessage': false});
    }
  }

  Query _getBaseQuery({required String docId}) {
    return _firestore
        .collection('messages')
        .doc(docId)
        .collection('conversations')
        .orderBy('dateTime', descending: true);
  }

  Stream<QuerySnapshot> getConversationsStream({
    required String docId,
    DocumentSnapshot? startAfterDocument,
    DocumentSnapshot? endBeforeDocument,
    int? limit,
  }) {
    var query = _getBaseQuery(docId: docId);

    if (endBeforeDocument != null) {
      query = query.endBeforeDocument(endBeforeDocument);
    }

    if (startAfterDocument != null) {
      query = query.startAfterDocument(startAfterDocument);
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots();
  }

  Future<QuerySnapshot> getOldMessagesQuery({
    required String docId,
    DocumentSnapshot? lastDocument,
    int limit = 15,
  }) async {
    var query = _getBaseQuery(docId: docId);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    return await query.limit(limit).get();
  }

  Future<void> updateTypingStatus({
    required String userId,
    required bool isTyping
  }) async {
    await _firestore.collection('accounts').doc(userId).update({
      'isTyping': isTyping,
    });
  }

  Future<void> clearConversations({required String docId}) async {
    await _firestore.collection('messages').doc(docId).delete();
  }

  Future<void> deleteMessages({
    required String docId,
    required List<String> messagesIds,
  }) async {
    final writeBatch = _firestore.batch();

    for (String messageId in messagesIds) {
      final docRef = _firestore
          .collection('messages')
          .doc(docId)
          .collection('conversations')
          .doc(messageId);
      writeBatch.delete(docRef);
    }

    await writeBatch.commit();
  }

  Future<void> sendMessage({
    required String docId,
    required ConversationModel conversation,
  }) async {
    final doc = _firestore
        .collection('messages')
        .doc(docId)
        .collection('conversations')
        .doc();
    conversation.messageId = doc.id;
    await doc.set(conversation.toJson());
  }

  DocumentReference getMessageDocumentReference({
    required String docId,
    required String messageId
  }) {
    return _firestore
        .collection('messages')
        .doc(docId)
        .collection('conversations')
        .doc(messageId);
  }
}