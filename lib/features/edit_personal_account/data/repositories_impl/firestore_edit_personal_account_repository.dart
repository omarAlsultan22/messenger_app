import '../models/post_model.dart';
import '../../../../core/data/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_app/core/data/data_sources/remote/firestore/firestore_base_service.dart';
import 'package:test_app/features/edit_personal_account/domain/repositories/edit_personal_account_repository.dart';


class FirestoreEditPersonalAccountRepository implements EditPersonalAccountRepository {
  final FirestoreBaseService _service;

  FirestoreEditPersonalAccountRepository({
    required FirestoreBaseService service}) : _service = service;

  @override
  Future<List<DocumentSnapshot<Map<String, dynamic>>>> getAccountData({
    required String userId
  }) async {
    final result = await Future.wait([
      _service.getDocument(collectionPath: 'accounts', docId: userId),
      _service.getDocument(collectionPath: 'info', docId: userId)
    ]);
    return result;
  }

  @override
  void updateAccountDataExecute({
    required String userId,
    required String userImage,
    required String userName,
    required String userState,
}) async {
    final docRef = _service.createDoc(collectionPath: 'posts');

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
      userName: userName,
      userImage: docRef.path,
    );

    try {
      await Future.wait([
        _service.addData(collectionPath: 'posts', data: postModel.toJson()),
        _service.updateDocument(
            docId: userId,
            collectionPath: 'accounts',
            data: userModel.toJson()),
        _service.updateDocument(
            docId: userId,
            collectionPath: 'info',
            data: {'userState': userState})
      ]);
      getAccountData(userId: userId);
    }
    catch (e) {
      rethrow;
    }
  }
}