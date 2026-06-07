import 'conversation_model.dart';


class MessageGroup {
  String? date;
  final DateTime sortDate;
  final List<ConversationModel> messages;

  MessageGroup({
    required this.date,
    required this.messages,
    required this.sortDate,
  });

  MessageGroup copyWith({
    String? date,
    DateTime? sortDate,
    List<ConversationModel>? messages,
  }) {
    return MessageGroup(
      date: date ?? this.date,
      sortDate: sortDate ?? this.sortDate,
      messages: messages ?? this.messages,
    );
  }

  void addNewMessages({
    required List<ConversationModel> messages
  }) => this.messages.addAll(messages);

  void insertAllMessages(List<ConversationModel> messages) =>
      this.messages.insertAll(0, messages);
}