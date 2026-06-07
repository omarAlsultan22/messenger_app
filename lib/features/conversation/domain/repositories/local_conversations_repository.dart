abstract class LocalConversationsRepository {
  Future<Map<String, dynamic>> getSavedBackgroundColorAndImage({
    required String docId
  });
}