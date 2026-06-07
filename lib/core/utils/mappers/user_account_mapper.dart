import 'package:cloud_firestore/cloud_firestore.dart';


abstract class UserAccountMapper {
  static Future<Map<String, dynamic>> enrichUserAccount({
    required Map<String, dynamic> userAccount,
  }) async {
    try {
      if (userAccount['userImage'] is DocumentReference) {
        final imageDocRef = userAccount['userImage'] as DocumentReference;
        final imageDoc = await imageDocRef.get();

        if (imageDoc.exists && imageDoc.data() != null) {
          final imageData = imageDoc.data() as Map<String, dynamic>;
          userAccount['userImage'] = imageData['userPost'] as String? ?? '';
        } else {
          userAccount['userImage'] = '';
        }
      }
      return userAccount;
    }
    catch (e) {
      rethrow;
    }
  }
}