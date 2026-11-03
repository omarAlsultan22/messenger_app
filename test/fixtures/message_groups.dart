import 'package:test_app/features/conversation/data/models/message_group.dart';
import 'package:test_app/features/conversation/data/models/conversation_model.dart';


final message1 = ConversationModel(messageId: 'm1', text: 'A');
final message2 = ConversationModel(messageId: 'm2', text: 'B');
final message3 = ConversationModel(messageId: 'm3', text: 'C');

final groupA = MessageGroup(
  messages: [message1, message2],
  sortDate: DateTime(2024, 5, 1),
  date: DateTime(2024, 5, 1).toString()
);

final groupB = MessageGroup(
  messages: [message3],
  sortDate: DateTime(2024, 5, 1),
  date: DateTime(2024, 5, 2).toString(),
);