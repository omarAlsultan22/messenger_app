import '../../utils/date_converter.dart';
import '../../data/models/message_group.dart';
import '../../data/models/conversation_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../repositories/remote_conversations_repository.dart';
import 'package:test_app/features/conversation/data/models/data_model.dart';


class GetOldMessagesUseCase {
  final RemoteConversationsRepository _repository;

  GetOldMessagesUseCase({required RemoteConversationsRepository repository})
      : _repository = repository;

  Future<DataModel> execute({
    required String docId,
    DocumentSnapshot? lastDocument,
  }) async {
    final snapshot = await _repository.getOldMessagesQuery(
      docId: docId,
      lastDocument: lastDocument,
      limit: 15,
    );

    if (snapshot.docs.isEmpty) {
      return DataModel(conversationList: []);
    }

    final conversations = snapshot.docs
        .map((doc) =>
        ConversationModel.fromJson(json: doc.data() as Map<String, dynamic>))
        .toList()
        .reversed
        .toList();

    final conversationList = _groupMessagesByDate(conversations);
    return DataModel(
        lastDocument: snapshot.docs.last,
        conversationList: conversationList
    );
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