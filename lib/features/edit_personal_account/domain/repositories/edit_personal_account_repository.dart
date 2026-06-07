import 'package:cloud_firestore/cloud_firestore.dart';


abstract class EditPersonalAccountRepository {
  Future<List<DocumentSnapshot<Map<String, dynamic>>>> getAccountData({
    required String userId
  });

  updateAccountDataExecute({
    required String userId,
    required String userImage,
    required String userName,
    required String userState,
  });
}