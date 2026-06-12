import 'package:cloud_firestore/cloud_firestore.dart';


abstract class EditPersonalAccountRepository {
  Future<List<DocumentSnapshot<Map<String, dynamic>>>> getAccountData({
    required String userId
  });

  updateAccountData({
    required String userId,
    required String userImage,
    required String firstName,
    required String lastName,
    required String userState,
  });
}