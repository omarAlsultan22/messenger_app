import '../repositories/remote_conversation_repository.dart';


class UpdateUnreadMessagesUseCase {
  final RemoteConversationRepository _repository;

  UpdateUnreadMessagesUseCase({required RemoteConversationRepository repository})
      : _repository = repository;

  Future<void> execute({required String docId}) async {
    await _repository.updateUnreadMessages(docId: docId);
  }
}