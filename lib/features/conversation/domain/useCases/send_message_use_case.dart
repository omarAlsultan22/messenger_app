import '../../data/models/message_group.dart';
import '../../data/models/conversation_model.dart';
import '../repositories/remote_conversations_repository.dart';


class SendMessageUseCase {
  final RemoteConversationsRepository _repository;

  SendMessageUseCase({required RemoteConversationsRepository repository})
      : _repository = repository;

  Future<void> execute({
    required String docId,
    required ConversationModel conversation,
    required List<MessageGroup> conversationsList,
    required Function(List<ConversationModel>) organizeMessages,
  }) async {
    await _repository.sendMessage(
      docId: docId,
      conversation: conversation,
    );
    organizeMessages([conversation]);
  }
}