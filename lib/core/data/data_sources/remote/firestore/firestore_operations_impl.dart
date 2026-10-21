import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_app/core/constants/app_durations.dart';
import '../../../../domain/data_sources/firestore/firestore_operations.dart';


class FirestoreOperationsImpl implements FirestoreOperations{
  final firestore = FirebaseFirestore.instance;

  @override
  Future<DocumentSnapshot<Map<String, dynamic>>> getDocument({
    required String collectionPath,
    required String? docId,
  }) async {
    return await firestore.collection(collectionPath).doc(docId).get().timeout(AppDurations.seconds);
  }
}