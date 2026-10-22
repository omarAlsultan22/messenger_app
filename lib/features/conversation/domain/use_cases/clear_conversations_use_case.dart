import '../repositories/remote_conversation_repository.dart';


class ClearConversationsUseCase {
  final RemoteConversationRepository _repository;

  ClearConversationsUseCase({required RemoteConversationRepository repository})
      : _repository = repository;

  Future<void> execute({required String docId}) async {
    await _repository.clearConversations(docId: docId);
  }
}