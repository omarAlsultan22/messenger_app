import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_app/core/constants/app_durations.dart';


class FirestoreBaseOperations{
  static final _firestore = FirebaseFirestore.instance;
  Future<DocumentSnapshot<Map<String, dynamic>>> getDocument({
    required String collectionPath,
    required String? docId,
  }) async {
    return await _firestore.collection(collectionPath).doc(docId).get().timeout(AppDurations.seconds);
  }
}