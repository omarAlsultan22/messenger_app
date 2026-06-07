import 'dart:async';
import '../../utils/date_converter.dart';
import '../../data/models/message_group.dart';
import '../../data/models/conversation_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../repositories/remote_conversations_repository.dart';
import 'package:test_app/features/conversation/data/models/data_model.dart';


class GetConversationsUseCase {
  final RemoteConversationsRepository _repository;

  GetConversationsUseCase({required RemoteConversationsRepository repository})
      : _repository = repository;

  Stream<DataModel> execute({
    String? senderId,
    required String docId,
    bool isEmptyList = false,
    DocumentSnapshot? firstDocument,
    DocumentSnapshot? lastDocument,
  }) {
    var query = _repository.getConversationsStream(
      docId: docId,
      endBeforeDocument: firstDocument,
      startAfterDocument: lastDocument,
      limit: isEmptyList ? 15 : null,
    );

    return query.asyncMap((snapshot) async {
      if (snapshot.docs.isEmpty) {
        return DataModel(conversationList: []);
      }

      final conversations = snapshot.docs
          .map((doc) {
        if (doc.data() is Map<String, dynamic>) {
          final data = doc.data() as Map<String, dynamic>;
          if (data['senderId'] == senderId) {
            return null;
          }
          return ConversationModel.fromJson(json: data);
        }
        return null;
      })
          .where((conversation) => conversation != null)
          .toList()
          .reversed
          .toList();

      final conversationList = _groupMessagesByDate(
          conversations.cast<ConversationModel>());
      return DataModel(
          firstDocument: snapshot.docs.first,
          lastDocument: snapshot.docs.last,
          conversationList: conversationList
      );
    });
  }

  List<MessageGroup> _groupMessagesByDate(List<ConversationModel> messages) {
    if (messages.isEmpty) return [];

    Map<String, List<ConversationModel>> groupedMessages = {};

    for (var message in messages) {
      if (message.dateTime == null) continue;

      final messageDate = DateTime(
          message.dateTime!.year,
          message.dateTime!.month,
          message.dateTime!.day);

      final header = DateConverter.getDateHeader(messageDate);
      groupedMessages.putIfAbsent(header, () => []);
      groupedMessages[header]!.add(message);
    }

    return groupedMessages.entries.map((entry) {
      final date = DateTime(
          entry.value.last.dateTime!.year,
          entry.value.last.dateTime!.month,
          entry.value.last.dateTime!.day);

      return MessageGroup(
        date: entry.key,
        messages: entry.value,
        sortDate: date,
      );
    }).toList();
  }
}