import '../repositories/local_conversations_repository.dart';


class GetBackgroundUseCase {
  final LocalConversationsRepository _repository;

  GetBackgroundUseCase({required LocalConversationsRepository repository})
      : _repository = repository;

  Future<Map<String, dynamic>> execute({required String docId}) async {
    return await _repository.getSavedBackgroundColorAndImage(docId: docId);
  }
}