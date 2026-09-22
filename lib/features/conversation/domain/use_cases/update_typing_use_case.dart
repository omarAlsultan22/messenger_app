import 'package:firebase_auth/firebase_auth.dart';
import '../repositories/remote_conversations_repository.dart';


class UpdateTypingUseCase {
  final RemoteConversationsRepository _repository;
  final FirebaseAuth _auth;

  UpdateTypingUseCase({
    required RemoteConversationsRepository repository,
    FirebaseAuth? auth,
  })
      : _repository = repository,
        _auth = auth ?? FirebaseAuth.instance;

  Future<void> execute(bool isTyping) async {
    if (_auth.currentUser == null) return;
    await _repository.updateTypingStatus(
        userId: _auth.currentUser!.uid, isTyping: isTyping);
  }
}