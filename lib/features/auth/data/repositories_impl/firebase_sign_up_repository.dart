import '../../../../core/data/models/user_model.dart';
import '../../domain/repositories/sign_up_repository.dart';
import '../../../../core/data/data_sources/remote/firestore/firestore_service.dart';


class FirebaseSignUpRepository implements SignUpRepository {
  final FirestoreService _repository;

  FirebaseSignUpRepository({
    required FirestoreService repository
  }) : _repository = repository;

  @override
  Future<void> createUserInfo({
    required UserModel userModel,
  }) async {
    try {
      await _repository.setData(
          collectionPath: 'accounts',
          docId: userModel.userId ?? '',
          data: userModel.toJson());
    } catch (e) {
      rethrow;
    }
  }
}