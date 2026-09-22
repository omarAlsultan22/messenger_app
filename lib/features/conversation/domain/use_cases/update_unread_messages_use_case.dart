import '../repositories/remote_conversations_repository.dart';


class UpdateUnreadMessagesUseCase {
  final RemoteConversationsRepository _repository;

  UpdateUnreadMessagesUseCase({required RemoteConversationsRepository repository})
      : _repository = repository;

  Future<void> execute({required String docId}) async {
    await _repository.updateUnreadMessages(docId: docId);
  }
}