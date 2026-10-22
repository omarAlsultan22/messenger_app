import '../../data/models/conversation_model.dart';
import '../repositories/remote_conversation_repository.dart';


class SendMessageUseCase {
  final RemoteConversationRepository _repository;

  SendMessageUseCase({required RemoteConversationRepository repository})
      : _repository = repository;

  Future<void> execute({
    required String docId,
    required ConversationModel conversation,
    required Function(List<ConversationModel>) organizeMessages,
  }) async {
    await _repository.sendMessage(
      docId: docId,
      conversation: conversation,
    );
    organizeMessages([conversation]);
  }
}