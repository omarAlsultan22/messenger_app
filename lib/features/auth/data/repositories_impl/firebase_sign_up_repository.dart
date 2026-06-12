import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/data/models/user_model.dart';
import '../../domain/repositories/sign_up_repository.dart';
import '../../../../core/data/data_sources/remote/firestore/firestore_base_service.dart';


class FirebaseSignUpRepository implements SignUpRepository {
  final FirestoreBaseService _repository;

  FirebaseSignUpRepository({
    required FirestoreBaseService repository
  }) : _repository = repository;

  @override
  Future<void> createUserInfo({
    required UserModel userModel,
    required UserCredential userCredential
  }) async {
    try {
      await _repository.setData(
          collectionPath: 'accounts',
          docId: userCredential.user!.uid,
          data: userModel.toJson());
    } catch (e) {
      rethrow;
    }
  }
}