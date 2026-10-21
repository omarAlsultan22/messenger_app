import '../models/post_model.dart';
import '../../../../core/data/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/domain/data_sources/firestore/firestore_service.dart';
import 'package:test_app/features/edit_personal_account/domain/repositories/edit_personal_account_repository.dart';


class EditPersonalAccountRepositoryImpl implements EditPersonalAccountRepository {
  final FirestoreService _dataSource;

  EditPersonalAccountRepositoryImpl({
    required FirestoreService dataSource}) : _dataSource = dataSource;

  @override
  Future<List<DocumentSnapshot<Map<String, dynamic>>>> getAccountData({
    required String userId
  }) async {
    final result = await Future.wait([
      _dataSource.getDocument(collectionPath: 'accounts', docId: userId),
      _dataSource.getDocument(collectionPath: 'info', docId: userId)
    ]);
    return result;
  }

  @override
  void updateAccountData({
    required String userId,
    required String userImage,
    required String firstName,
    required String lastName,
    required String userState
  }) async {
    final docRef = _dataSource.createDoc(collectionPath: 'posts');

    PostModel postModel = PostModel(
      userText: '',
      userId: userId,
      docId: docRef.id,
      postType: 'profileImage',
      userPost: userImage,
      dateTime: DateTime.now(),
      userState: 'public',
    );

    UserModel userModel = UserModel(
      firstName: firstName,
      lastName: lastName,
      fullName: '$firstName''$lastName',
      userImage: docRef.path,
    );

    await Future.wait([
      _dataSource.addData(collectionPath: 'posts', data: postModel.toJson()),
      _dataSource.updateDocument(
          docId: userId,
          collectionPath: 'accounts',
          data: userModel.toJson()),
      _dataSource.updateDocument(
          docId: userId,
          collectionPath: 'info',
          data: {'userState': userState})
    ]);
    getAccountData(userId: userId);
  }
}