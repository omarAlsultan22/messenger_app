abstract class LocalConversationRepository {
  Future<Map<String, dynamic>> getSavedBackgroundColorAndImage({
    required String docId
  });
}