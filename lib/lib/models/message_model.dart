import 'conversation_model.dart';

class MessageGroup {
  final String title;
  final List<ConversationModel> messages;
  final DateTime sortDate;

  MessageGroup({
    required this.title,
    required this.messages,
    required this.sortDate,
  });
}