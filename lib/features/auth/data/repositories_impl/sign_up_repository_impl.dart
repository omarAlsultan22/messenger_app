import '../../../../core/data/models/user_model.dart';
import '../../domain/repositories/sign_up_repository.dart';
import '../../../../core/domain/services/firestore/firestore_service.dart';


class SignUpRepositoryImpl implements SignUpRepository {
  final FirestoreService _service;

  SignUpRepositoryImpl({
    required FirestoreService repository
  }) : _service = repository;

  @override
  Future<void> createUserInfo({
    required UserModel userModel,
  }) async {
    await _service.setData(
        collectionPath: 'accounts',
        docId: userModel.userId ?? '',
        data: userModel.toJson());
  }
}