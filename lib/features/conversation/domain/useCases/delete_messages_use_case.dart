import '../../data/models/message_group.dart';
import '../repositories/remote_conversations_repository.dart';


class DeleteMessagesUseCase {
  final RemoteConversationsRepository _repository;

  DeleteMessagesUseCase({required RemoteConversationsRepository repository})
      : _repository = repository;

  Future<void> execute({
    required String docId,
    required List<String> messagesIds,
    required List<MessageGroup> conversationList,
  }) async {
    // تحديث الـ List المحلي
    for (var group in conversationList) {
      final originalCount = group.messages.length;
      group.messages.removeWhere((e) => messagesIds.contains(e.messageId));

      if (group.messages.isEmpty && originalCount > 0) {
        group.copyWith(date: null);
      }
    }

    // حذف من Firestore
    await _repository.deleteMessages(
      docId: docId,
      messagesIds: messagesIds,
    );

    // إزالة المجموعات الفارغة
    conversationList.removeWhere((group) => group.messages.isEmpty);
  }
}