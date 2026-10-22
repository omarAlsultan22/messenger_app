import '../repositories/local_conversation_repository.dart';


class GetBackgroundUseCase {
  final LocalConversationRepository _repository;

  GetBackgroundUseCase({required LocalConversationRepository repository})
      : _repository = repository;

  Future<Map<String, dynamic>> execute({required String docId}) async {
    return await _repository.getSavedBackgroundColorAndImage(docId: docId);
  }
}