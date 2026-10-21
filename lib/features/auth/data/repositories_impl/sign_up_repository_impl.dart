import '../../../../core/data/models/user_model.dart';
import '../../domain/repositories/sign_up_repository.dart';
import '../../../../core/domain/data_sources/firestore/firestore_service.dart';


class SignUpRepositoryImpl implements SignUpRepository {
  final FirestoreService _dataSource;

  SignUpRepositoryImpl({
    required FirestoreService dataSource
  }) : _dataSource = dataSource;

  @override
  Future<void> createUserInfo({
    required UserModel userModel,
  }) async {
    await _dataSource.setData(
        collectionPath: 'accounts',
        docId: userModel.userId ?? '',
        data: userModel.toJson());
  }
}