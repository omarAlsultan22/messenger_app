import '../repositories/remote_conversations_repository.dart';


class ClearConversationsUseCase {
  final RemoteConversationsRepository _repository;

  ClearConversationsUseCase({required RemoteConversationsRepository repository})
      : _repository = repository;

  Future<void> execute({required String docId}) async {
    await _repository.clearConversations(docId: docId);
  }
}